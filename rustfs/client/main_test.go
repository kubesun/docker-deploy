package main

import (
	"context"
	"fmt"
	"io"
	"log"
	"os"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

var bucketName = aws.String("test")
var ctx = context.Background()
var fileName = aws.String("test.txt")

func NewAwsClient() *s3.Client {
	// region := os.Getenv("RUSTFS_REGION")
	// access_key_id := os.Getenv("RUSTFS_ACCESS_KEY_ID")
	// secret_access_key := os.Getenv("RUSTFS_SECRET_ACCESS_KEY")
	// endpoint := os.Getenv("RUSTFS_ENDPOINT_URL")
	// if access_key_id == "" || secret_access_key == "" || region == "" || endpoint == "" {
	// 	log.Fatal("missing the env: RUSTFS_ACCESS_KEY_ID / RUSTFS_SECRET_ACCESS_KEY / RUSTFS_REGION / RUSTFS_ENDPOINT_URL")
	// }

	region := "ap-northeast-1"
	secretAccessKey := "qzQjpL0SCElPtVR45hvMIwbuiAaTnKXFo8WxYs7D"
	accessKeyId := "Bc4KIpqrX69nuYyVz7fs"
	endpoint := "https://apikv.com:9000"
	// usePathStyle := strings.ToLower(os.Getenv("AWS_S3_USE_PATH_STYLE")) == "true"

	// build aws.Config
	cfg := aws.Config{
		Region: region,
		EndpointResolver: aws.EndpointResolverFunc(func(service, region string) (aws.Endpoint, error) {
			return aws.Endpoint{
				URL: endpoint,
			}, nil
		}),
		Credentials: aws.NewCredentialsCache(credentials.NewStaticCredentialsProvider(accessKeyId, secretAccessKey, "")),
	}

	// build S3 client
	client := s3.NewFromConfig(cfg, func(o *s3.Options) {
		o.UsePathStyle = true
	})

	return client
}

func TestMain(m *testing.M) {
	client := NewAwsClient()
	exitCode := m.Run()

	if client != nil {
		t := testing.T{}
		deleteBucket(client, &t)
	}

	if exitCode != 0 {
		os.Exit(exitCode)
	}
}

func TestAwsFlow(t *testing.T) {
	client := NewAwsClient()

	createBucket(client, t)
	upload(client, t)
	listObject(client, t)
	download(client, t)
}

func listObject(client *s3.Client, t *testing.T) {
	resp, err := client.ListObjectsV2(ctx, &s3.ListObjectsV2Input{
		// Bucket: aws.String("bucket-target"),
		Bucket: bucketName,
	})
	if err != nil {
		log.Fatalf("list object failed: %v", err)
	}
	for _, obj := range resp.Contents {
		fmt.Println(" -", *obj.Key)
	}
}

func upload(client *s3.Client, t *testing.T) {

	_, err := client.PutObject(ctx, &s3.PutObjectInput{
		Bucket: bucketName,
		Key:    fileName,
		Body:   strings.NewReader("hello rustfs"),
	})
	if err != nil {
		log.Fatalf("upload object failed: %v", err)
	}
}

func createBucket(client *s3.Client, t *testing.T) {

	_, err := client.CreateBucket(ctx, &s3.CreateBucketInput{
		Bucket: bucketName,
	})
	if err != nil {
		log.Fatalf("create bucket failed: %v", err)
	}
}

func download(client *s3.Client, t *testing.T) {
	resp, err := client.GetObject(ctx, &s3.GetObjectInput{
		Bucket: bucketName,
		Key:    fileName,
	})
	if err != nil {
		log.Fatalf("download object fail: %v", err)
	}
	defer resp.Body.Close()

	// read object content
	data, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Fatalf("read object content fail: %v", err)
	}
	fmt.Println("content is :", string(data))
}

func deleteBucket(client *s3.Client, t *testing.T) {
	_, err := client.DeleteBucket(ctx, &s3.DeleteBucketInput{
		Bucket: bucketName,
	})
	if err != nil {
		log.Fatalf("delete bucket failed: %v", err)
	}
}
