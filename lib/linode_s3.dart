import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:amazon_cognito_identity_dart_2/sig_v4.dart';

class AWSClient {
  String accessKeyId =
      '5LNW4G2F71F5OHJTPV0Q'; // replace with your own access key
  String secretKeyId =
      'LAjB0AqX4E04duDMReRuDz1PrtSjT48gDReuUK8d'; // replace with your own secret key
  String region = 'ap-south-1'; // replace with your account's region name
  String bucketname = "mybucket69420"; // replace with your S3's bucket name
  String s3Endpoint =
      'https://mybucket69420.ap-south-1.linodeobjects.com'; // update the endpoint url for your bucket

  dynamic uploadData(String folderName, String fileName, Uint8List data) async {
    final length = data.length;

    final uri = Uri.parse(s3Endpoint);
    final req = http.MultipartRequest("POST", uri);
    final multipartFile = http.MultipartFile(
        'file', http.ByteStream.fromBytes(data), length,
        filename: fileName);

    // final policy = Policy.fromS3PresignedPost(
    //     , bucketname, accessKeyId, 15, length,
    //     region: region);
    final policy = Policy.fromS3PresignedPost(
        folderName + '/' + fileName,
        bucketname,
        15,
        accessKeyId,
        length,
        // _credentials.sessionToken,
        region: region);
    final key =
    SigV4.calculateSigningKey(secretKeyId, policy.datetime, region, 's3');
    final signature = SigV4.calculateSignature(key, policy.encode());

    req.files.add(multipartFile);
    req.fields['key'] = policy.key;
    req.fields['acl'] = 'public-read';
    req.fields['X-Amz-Credential'] = policy.credential;
    req.fields['X-Amz-Algorithm'] = 'AWS4-HMAC-SHA256';
    req.fields['X-Amz-Date'] = policy.datetime;
    req.fields['Policy'] = policy.encode();
    req.fields['X-Amz-Signature'] = signature;
    var rsusts;
    try {
      final res = await req.send();
      // final respStr = await res.stream.bytesToString();
      return res.statusCode;
    } catch (e) {
      log(e.toString());

      return e;
    }
  }
}

class Policy {
  String expiration;
  String region;
  String bucket;
  String key;
  String credential;
  String datetime;
  // String sessionToken;
  int maxFileSize;

  Policy(
      this.key,
      this.bucket,
      this.datetime,
      this.expiration,
      this.credential,
      this.maxFileSize,
      // this.sessionToken,
      {this.region = 'us-east-1'}
      );

  factory Policy.fromS3PresignedPost(
      String key,
      String bucket,
      int expiryMinutes,
      String accessKeyId,
      int maxFileSize,
      // String sessionToken,
      {required String region}
      ) {
    final datetime = SigV4.generateDatetime();
    final expiration = (DateTime.now())
        .add(Duration(minutes: expiryMinutes))
        .toUtc()
        .toString()
        .split(' ')
        .join('T');
    final cred =
        '$accessKeyId/${SigV4.buildCredentialScope(datetime, region, 's3')}';
    final p = Policy(
        key, bucket, datetime, expiration, cred, maxFileSize,
        // sessionToken,
        region: region);
    return p;
  }

  String encode() {
    final bytes = utf8.encode(toString());
    return base64.encode(bytes);
  }

  @override
  String toString() {
    // Safe to remove the "acl" line if your bucket has no ACL permissions
    return '''
    { "expiration": "${this.expiration}",
      "conditions": [
        {"bucket": "${this.bucket}"},
        ["starts-with", "\$key", "${this.key}"],
        {"acl": "public-read"},
        ["content-length-range", 1, ${this.maxFileSize}],
        {"x-amz-credential": "${this.credential}"},
        {"x-amz-algorithm": "AWS4-HMAC-SHA256"},
        {"x-amz-date": "${this.datetime}" },
        
      ]
    }
    ''';
  }
}
// {"x-amz-security-token": "${this.sessionToken}" }