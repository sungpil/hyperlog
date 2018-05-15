Hyper log
=========

> 하이퍼 캐쥬얼 게임용 로그 수집 서버

### Concept

```
┌─────── EC2s ──────┐      ┌─────────┐                  ┌──────────┐   ┌─────┐   
│     webserver     │──────│ Kinesis │─┐              ┌─│ Firehose │───│ S3  │
│ aws-Kinesis-agent │      └─────────┘ │              │ └──────────┘   └─────┘
└───────────────────┘   .              │              │      .            .
                        .              │  ┌────────┐  │      .            .
                        .              ├──│ Lambda │──┤      .            .
                        .              │  └────────┘  │      .            .
┌─────── EC2s───────┐   .              │              │      .            .
│     webserver     │      ┌─────────┐ │              │ ┌──────────┐   ┌─────┐
│ aws-Kinesis-agent │──────│ Kinesis │─┘              └─│ Firehose │───│ S3  │
└───────────────────┘      └─────────┘                  └──────────┘   └─────┘     
```
- EC2s - 확장 가능한 Ec2( 웹서버, aws-kiensis-agent ) 서버 그룹 - 서버 그룹은 특정 kinesis 와 연결
- Kinesis - kinesis는 로그 스트림을 저장한다. 로드가 높아지면 [ EC2s - kiensis ] 를 추가한다.
- Kinesis에 정해진 주기적으로 정해진 시간/사이즈 단위로 Lambda 호출
- Lambda 는 로그를 분석해서 게임별 Firehose 로 로그 전달
- Firehose 는 정해진 시간/크기별로 로그를 나누어 S3 에 로그 적재

### Structure
### EC2 설정
### Kiensis 설정
### Lambda 설정
### FireHose 설정
