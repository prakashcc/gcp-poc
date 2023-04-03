#/bin/sh

export REGION=us-central1
export CLUSTER_NAME=prophecy
gcloud dataproc clusters create ${CLUSTER_NAME} --enable-component-gateway --region ${REGION}  --initialization-actions gs://prophecy_prutech_demo/livy/livy.sh  --metadata livy-version=0.7.0

gcloud composer environments create prophecy --location ${REGION} --image-version composer-1.20.10-airflow-2.4.3 --service-account "462580942836-compute@developer.gserviceaccount.com"


gcloud dataproc workflow-templates create prophecy --region=us-central1

gcloud dataproc workflow-templates add-job spark --workflow-template=prophecy --step-id=compute --class=org.apache.spark.examples.SparkPi --jars=file:///usr/lib/spark/examples/jars/spark-examples.jar --region=us-central1 -- 1000
      
gcloud dataproc workflow-templates set-managed-cluster prophecy --cluster-name=prophecy --single-node --region=us-central1

gcloud dataproc workflow-templates describe prophecy --region=us-central1






      


      
      