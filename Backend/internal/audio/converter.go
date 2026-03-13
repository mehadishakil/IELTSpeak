package audio

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"time"
)

// ConvertM4AToWAV converts an M4A file to WAV (16kHz, mono, PCM s16le) using ffmpeg.
func ConvertM4AToWAV(inputPath, outputPath string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	cmd := exec.CommandContext(ctx, "ffmpeg",
		"-i", inputPath,
		"-acodec", "pcm_s16le",
		"-ar", "16000",
		"-ac", "1",
		"-f", "wav",
		"-y",
		outputPath,
	)

	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("ffmpeg conversion failed: %w, output: %s", err, string(output))
	}

	return nil
}

// GetAudioDuration returns the duration of an audio file in seconds using ffprobe.
func GetAudioDuration(filePath string) (float64, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	cmd := exec.CommandContext(ctx, "ffprobe",
		"-v", "quiet",
		"-show_entries", "format=duration",
		"-of", "default=noprint_wrappers=1:nokey=1",
		filePath,
	)

	output, err := cmd.Output()
	if err != nil {
		return 0, fmt.Errorf("ffprobe failed: %w", err)
	}

	duration, err := strconv.ParseFloat(strings.TrimSpace(string(output)), 64)
	if err != nil {
		return 0, fmt.Errorf("failed to parse duration: %w", err)
	}

	return duration, nil
}

// SplitAudioIntoChunks splits a WAV file into chunks of maxDuration seconds using ffmpeg.
// Returns paths to chunk files. Caller is responsible for cleaning up chunk files.
func SplitAudioIntoChunks(inputPath string, maxDuration float64) ([]string, error) {
	totalDuration, err := GetAudioDuration(inputPath)
	if err != nil {
		return nil, err
	}

	// No split needed
	if totalDuration <= maxDuration {
		return []string{inputPath}, nil
	}

	tmpDir := os.TempDir()
	baseName := filepath.Base(strings.TrimSuffix(inputPath, filepath.Ext(inputPath)))

	var chunks []string
	chunkStart := 0.0
	chunkIndex := 0

	for chunkStart < totalDuration {
		chunkDuration := maxDuration
		remaining := totalDuration - chunkStart
		if remaining < chunkDuration {
			chunkDuration = remaining
		}

		// Skip tiny trailing chunks (<2s)
		if chunkDuration < 2.0 && chunkIndex > 0 {
			break
		}

		chunkPath := filepath.Join(tmpDir, fmt.Sprintf("%s_chunk%d_%d.wav", baseName, chunkIndex, time.Now().UnixNano()))

		ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		cmd := exec.CommandContext(ctx, "ffmpeg",
			"-i", inputPath,
			"-ss", fmt.Sprintf("%.3f", chunkStart),
			"-t", fmt.Sprintf("%.3f", chunkDuration),
			"-acodec", "pcm_s16le",
			"-ar", "16000",
			"-ac", "1",
			"-f", "wav",
			"-y",
			chunkPath,
		)

		output, err := cmd.CombinedOutput()
		cancel()

		if err != nil {
			// Clean up any chunks we already created
			for _, c := range chunks {
				CleanupFile(c)
			}
			return nil, fmt.Errorf("ffmpeg chunk split failed (chunk %d): %w, output: %s", chunkIndex, err, string(output))
		}

		chunks = append(chunks, chunkPath)
		chunkStart += chunkDuration
		chunkIndex++
	}

	if len(chunks) == 0 {
		return nil, fmt.Errorf("no chunks produced from audio file")
	}

	return chunks, nil
}

// SaveTempFile writes data to a temporary file and returns the path.
func SaveTempFile(data []byte, prefix, ext string) (string, error) {
	tmpDir := os.TempDir()
	path := filepath.Join(tmpDir, fmt.Sprintf("%s_%d%s", prefix, time.Now().UnixNano(), ext))

	if err := os.WriteFile(path, data, 0644); err != nil {
		return "", fmt.Errorf("failed to write temp file: %w", err)
	}

	return path, nil
}

// CleanupFile removes a file silently.
func CleanupFile(path string) {
	if path != "" {
		os.Remove(path)
	}
}
