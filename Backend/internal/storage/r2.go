package storage

import (
	"context"
	"fmt"
	"io"
	"log/slog"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

// R2Client wraps Cloudflare R2 (S3-compatible) operations.
type R2Client struct {
	client     *s3.Client
	presigner  *s3.PresignClient
	bucketName string
}

// NewR2Client creates a new Cloudflare R2 client using AWS SDK v2.
func NewR2Client(accountID, accessKey, secretKey, bucketName string) (*R2Client, error) {
	endpoint := fmt.Sprintf("https://%s.r2.cloudflarestorage.com", accountID)

	cfg := aws.Config{
		Region:       "auto",
		Credentials:  credentials.NewStaticCredentialsProvider(accessKey, secretKey, ""),
		BaseEndpoint: aws.String(endpoint),
	}

	client := s3.NewFromConfig(cfg, func(o *s3.Options) {
		o.UsePathStyle = true
	})

	presigner := s3.NewPresignClient(client)

	return &R2Client{
		client:     client,
		presigner:  presigner,
		bucketName: bucketName,
	}, nil
}

// GenerateUploadURL creates a pre-signed PUT URL for uploading audio to R2.
func (r *R2Client) GenerateUploadURL(ctx context.Context, key string, expiry time.Duration) (string, error) {
	req, err := r.presigner.PresignPutObject(ctx, &s3.PutObjectInput{
		Bucket: aws.String(r.bucketName),
		Key:    aws.String(key),
	}, s3.WithPresignExpires(expiry))
	if err != nil {
		return "", fmt.Errorf("failed to generate upload URL: %w", err)
	}
	return req.URL, nil
}

// GenerateDownloadURL creates a pre-signed GET URL for downloading audio from R2.
func (r *R2Client) GenerateDownloadURL(ctx context.Context, key string, expiry time.Duration) (string, error) {
	req, err := r.presigner.PresignGetObject(ctx, &s3.GetObjectInput{
		Bucket: aws.String(r.bucketName),
		Key:    aws.String(key),
	}, s3.WithPresignExpires(expiry))
	if err != nil {
		return "", fmt.Errorf("failed to generate download URL: %w", err)
	}
	return req.URL, nil
}

// DownloadFile downloads a file from R2 and returns its contents.
func (r *R2Client) DownloadFile(ctx context.Context, key string) ([]byte, error) {
	output, err := r.client.GetObject(ctx, &s3.GetObjectInput{
		Bucket: aws.String(r.bucketName),
		Key:    aws.String(key),
	})
	if err != nil {
		return nil, fmt.Errorf("failed to get object from R2: %w", err)
	}
	defer output.Body.Close()

	data, err := io.ReadAll(output.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read R2 object body: %w", err)
	}
	return data, nil
}

// DeleteFile removes a file from R2.
func (r *R2Client) DeleteFile(ctx context.Context, key string) error {
	_, err := r.client.DeleteObject(ctx, &s3.DeleteObjectInput{
		Bucket: aws.String(r.bucketName),
		Key:    aws.String(key),
	})
	if err != nil {
		slog.Warn("failed to delete R2 object", "key", key, "error", err)
		return err
	}
	return nil
}
