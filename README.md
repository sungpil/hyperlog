Hyper log
=========

> 하이퍼 캐쥬얼 게임용 로그 수집 서버

### Concept

```
┌─EC2-AutoScalingGroup─┐    ┌─────────┐                ┌──────────┐  ┌────┐   
│      webserver       ├────┤ Kinesis ├─┐            ┌─┤ Firehose ├──┤ S3 ├─┐
│   aws-Kinesis-agent  │    └─────────┘ │            │ └──────────┘  └────┘ │
└──────────────────────┘  .             │            │      .           .   │
                          .             │ ┌────────┐ │      .           .   │  ┌────────┐
                          .             ├─┤ Lambda ├─┤      .           .   ├──┤ Athena │
                          .             │ └────────┘ │      .           .   │  └────────┘ 
┌─EC2-AutoScalingGroup─┐  .             │            │      .           .   │
│       webserver      │    ┌─────────┐ │            │ ┌──────────┐  ┌────┐ │
│   aws-Kinesis-agent  ├────┤ Kinesis ├─┘            └─┤ Firehose ├──┤ S3 ├─┘
└──────────────────────┘    └─────────┘                └──────────┘  └────┘     
```
1. 클라에서 로그서버로 로그를 보내면
2. aws-Kinesis-agent 가 로그를 수집해서 kinesis로 전달
3. kinesis에 전달된 로그는 gameId 별로 분류하여 firehose 를 통해 s3 에 일자별로 저장
4. athena에서 s3의 로그를 분석

### EC2 
- EC2s - 확장 가능한 Ec2( 웹서버, aws-kiensis-agent ) 서버 그룹 - 서버 그룹은 특정 kinesis 와 연결
- user-data 에 로그를 전송할 kinesis stream 지정한다.
- config/www 를 체크아웃 받아 배포한다.
- init/deploy 스크립트는 scripts 디렉토리 참고
### Kiensis 
- kinesis에 부하가 생기면 ec2-AutoscailingGroup 과 kinesis를 추가해서 부하를 분산한다. 
### Lambda 
- kinesis_to_firehose   
kinesis의 스트림의 이벤트를 받아 로그를 gameId 별로 분류해서 각 gameId 별 firehose에 put  
- s3_for_athena  
s3의 파일을 athena가 파티셔닝 하도록 일자별로 디렉토리를 만들고 파일을 정리한다.  
### FireHose 
- 정해진 시간/크기별로 로그를 나누어 S3 에 로그 적재
### Athena 
- s3의 로그를 일자별로 파티셔닝 해서 분석
