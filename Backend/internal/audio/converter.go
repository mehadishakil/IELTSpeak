package audio

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
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

// SaveTempFile writes data to a temporary file and returns the path.
func SaveTempFile(data []byte, prefix, ext string) (string, error) {
	tmpDir := os.TempDir()
	path := filepath.Join(tmpDir, fmt.Sprintf("%s_%d%s", prefix, time.Now().UnixNano(), ext))

	if err := os.WriteFile(path, data, 0644); err != nil {
		return "", fmt.Errorf("failed to write temp file: %w", err)
	}

	return path, nil
}

// CleanupFile removes a file, logging but not returning errors.
func CleanupFile(path string) {
	if path != "" {
		os.Remove(path)
	}
}
