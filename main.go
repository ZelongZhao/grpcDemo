package main

import (
	"context"
	"errors"
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/grpc-ecosystem/grpc-gateway/v2/runtime"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	v1 "grpcDemo/v1"
	"io"
	"log"
	"net"
)

type HelloServiceImpl struct {
	v1.IMLoginServiceServer
}

func (impl *HelloServiceImpl) Login(
	ctx context.Context, request *v1.LoginRequest) (*v1.LoginResponse, error) {
	if request.Username == "allen" && request.Password == "123456" {
		return &v1.LoginResponse{
			Token: "111",
		}, nil
	} else {
		return nil, errors.New("用户名或密码错误")
	}
}

func (impl *HelloServiceImpl) Channel(s v1.IMLoginService_ChannelServer) error {
	for {
		arg, err := s.Recv()
		if err != nil {
			if err == io.EOF {
				return nil
			}
			return err
		}

		fmt.Println(arg.Str_)

		strRes := &v1.MyString{Str_: "hello " + arg.Str_}
		if err := s.Send(strRes); err != nil {
			return err
		}
	}
}

func main() {
	grpcServer := grpc.NewServer()
	v1.RegisterIMLoginServiceServer(grpcServer, new(HelloServiceImpl))

	lis, err := net.Listen("tcp", ":1234")
	if err != nil {
		log.Fatal(err)
	}

	go func() {
		log.Fatal(grpcServer.Serve(lis))
	}()

	client, err := grpc.NewClient("127.0.0.1:1234", grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatal(err)
	}

	gwMux := runtime.NewServeMux()
	regErr := v1.RegisterIMLoginServiceHandler(context.Background(), gwMux, client)
	if regErr != nil {
		log.Fatal(err)
	}

	r := gin.Default()

	r.Any("/*any", gin.WrapH(gwMux))

	//r.POST("/hello", func(c *gin.Context) {
	//	c.JSON(http.StatusOK, gin.H{"hello": "world"})
	//})

	r.Run(":1235")
}
