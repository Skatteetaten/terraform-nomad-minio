# Minio Standalone example

The current directory contains terraform related files that use the module in `../..`.
The [example minio module](main.tf) runs with [host volume](https://www.nomadproject.io/docs/job-specification/volume) enabled and the minio data is
saved in the `persistence/minio` folder.


## Example of file uploads

All data that will be loaded to minio are available [/example/resources/data](../resources/data)

### File types
- csv
- json
- avro
- protobuf

### AVRO scheme

Uses [avro-tools](https://formulae.brew.sh/formula/avro-tools)

Scheme
```json
{
  "type" : "record",
  "name" : "twitter_schema",
  "namespace" : "no.fredrikhgrelland.terraform.nomad.minio.avro",
  "fields" : [
    {
        "name" : "username",
        "type" : "string",
        "doc"  : "Name of the user account on Twitter.com"
    },
    {
        "name" : "tweet",
        "type" : "string",
        "doc"  : "The content of the user's Twitter message"
    },
    {
        "name" : "timestamp",
        "type" : "long",
        "doc"  : "Unix epoch time in seconds"
    }
  ],
  "doc:" : "A basic schema for storing Twitter messages"
}
```

### Protobuf

Uses [Protobuf](https://formulae.brew.sh/formula/protobuf) in example.

Scheme
```text
syntax = "proto3";

message Info {
  int32 id = 1;
  bool is_simple = 2;
  string name = 3;
  repeated int32 sample_list = 4;
}
```


## References
- [Creating Modules - official terraform documentation](https://www.terraform.io/docs/modules/index.html)
