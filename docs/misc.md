# Misc infos

## callback struct:
```bash
# in queue
{
    "action": "in_queue", 
    "prompt_id": prompt_id
}
# on s3 upload
{
    "action": "s3_upload",
    "prompt_id": prompt_id,
    "filename": filename,
    "data": s3_url,
    "execution_time": 123123123,
}
# on error
{
    "action": "error",
    "prompt_id": prompt_id,
    "errors": errors,
}
# on complete
{
    "action": "complete",
    "prompt_id": prompt_id,
    "result": final_result,
}
```

## examples
```bash
# on upload
{
   "action":"s3_upload",
   "prompt_id":"ee3f65df-c808-430d-93a6-4e9cdf66b1a8",
   "filename":"t2v_00007_.mp4",
   "data":"https://blablabla.amazonaws.com/ai/06-25/sync-3ff8534e-bbe6-42e7-9785-a742f8be72f3-e2/6cdb4932.mp4",
   "execution_time": 123123123,
}

# on complete
{
   "action":"complete",
   "prompt_id":"ee3f65df-c808-430d-93a6-4e9cdf66b1a8",
   "result":{
      "images":[
         {
            "filename":"t2v_00007_.mp4",
            "type":"s3_url",
            "data":"https://blablabla.amazonaws.com/ai/06-25/sync-3ff8534e-bbe6-42e7-9785-a742f8be72f3-e2/6cdb4932.mp4?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAQVXTBF5NPEK2YUYE%2F20250612%2Feu-central-1%2Fs3%2Faws4_request&X-Amz-Date=20250612T102425Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=fe0b9f7c14ac16c411c27f19268f7c24aa776abdfbcc7dfa32815ca9fdbced84"
         }
      ]
   }
}
```

# For runpod s3 access:
```bash
aws s3 ls --region EU-SE-1 --endpoint-url https://s3api-eur-se-1.runpod.io/ s3://sbo371gmlh/

# for filesize in human form
du -hs * | sort -h
```