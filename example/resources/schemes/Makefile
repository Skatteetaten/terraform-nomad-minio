# avro
encode-json-2-avro:
	avro-tools fromjson --codec snappy --schema-file ./avro/twitter_scheme.avsc ./avro/tweet1.json > ../data/avro-tweet/tweet1.snappy.avro
	avro-tools fromjson --codec snappy --schema-file ./avro/twitter_scheme.avsc ./avro/tweet2.json > ../data/avro-tweet/tweet2.snappy.avro

# protofub
encode-text-2-proto:
	mkdir cpp | true
	protoc --cpp_out=cpp ./proto/info.proto | true
	protoc --encode=Info ./proto/info.proto < ./proto/info1.text  > ../data/proto-message/info1.data
	protoc --encode=Info ./proto/info.proto < ./proto/info2.text  > ../data/proto-message/info2.data
	rm -rf cpp
hex:
	hexdump -C ../data/proto-message/info1.data
	hexdump -C ../data/proto-message/info2.data
decode-bin-2-text:
	protoc --decode Info ./proto/info.proto < ../data/proto-message/info1.data
	protoc --decode Info ./proto/info.proto < ../data/proto-message/info2.data
