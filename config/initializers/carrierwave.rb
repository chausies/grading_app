CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: "AWS",
    aws_access_key_id: "AKIAISILFS4Y6TF7YIWA",
    aws_secret_access_key: "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",
    region: 'us-west-1'
  }
  config.fog_directory = "magicgrader"
end