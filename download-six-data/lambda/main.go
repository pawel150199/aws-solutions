package main

import (
	"context"
	"fmt"
	"log"
	"net/http"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

type Request struct {
	URL			string		`json:"url"`
	BucketName	string   	`json:"bucketName"`
	ObjectName	string		`json:"objectName"`	
}

type Response struct {
	Message		string 		`json:"message"`
}

func lambdaHandler(ctx context.Context, req Request) (Response,  error) {
	resp, err := http.Get(req.URL)
	if err != nil {
		return Response{Message: "Failed to download data"},  fmt.Errorf("Failed to download data: %w", err)
	}

	defer  resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return Response{Message: "Response Status Code is not equal to 200"}, fmt.Errorf("Response Status code is not equal to 200: %w", err)
	}

	// Load AWS config
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		return Response{Message: "Failed to load AWS config"}, fmt.Errorf{"Failed to load AWS config: %w", err}
	}

	// Initialize S3 uploader
	uploader := s3manager.NewUploader(s3.NewFromConfig(cfg))

	// Upload data to specified S3 bucket
	_, err := uploader.PutObject(ctx, &s3.PutObjectInput{
		Bucket: aws.String(event.BucketName),
		Key:	aws.String(event.Key),
		Body: 	bytes.NewReader(resp.Body),
	})
	if err != nil {
		return Response{Message: "Failed to upload data to S3 bucket"}, fmt.Errorf("Failed to upload data to S3 bucket")
	}

	log.Printf("Successfully uploaded data to %s/%s", req.BucketName, req.ObjectName)
	return Response{Message: "Successfully uploaded data to S3"}, nil
}

func main() {
	lambda.Start(lambdaHandler)
}