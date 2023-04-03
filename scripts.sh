#/bin/sh

export REGION=us-central1
export CLUSTER_NAME=prophecy
export PROJECT=462580942836

gcloud config set project $PROJECT

gsutil mb -c regional -l us-central1 gs://prophecy_prutech_demo

bq mk ComposerDemo
export EXPORT_TS=`date "+%Y-%m-%dT%H%M%S"`&& bq extract \
--destination_format=NEWLINE_DELIMITED_JSON \
nyc-tlc:yellow.trips \
gs://prophecy_prutech_demo/cloud-composer-lab/raw-$EXPORT_TS/nyc-tlc-yellow-*.json


gcloud composer environments run \
prophecy\
--location=us-central1 variables -- \
--set gcp_project $PROJECT
gcloud composer environments run demo-ephemeral-dataproc \
--location=us-central1 variables -- \
--set gce_zone us-central1-b
gcloud composer environments run demo-ephemeral-dataproc \
--location=us-central1 variables -- \
--set gcs_bucket $PROJECT
gcloud composer environments run demo-ephemeral-dataproc \
--location=us-central1 variables -- \
--set bq_output_table $PROJECT:ComposerDemo.nyc-tlc-yellow-trips

gsutil cp spark_avg_speed.py gs://prophecy_prutech_demo/spark-jobs/

gsutil cp ephemeral_dataproc_spark_dag.py gs://us-central1-prophecy-60eab588-bucket

gcloud dataproc clusters create ${CLUSTER_NAME} --enable-component-gateway --region ${REGION}  --initialization-actions gs://prophecy_prutech_demo/livy/livy.sh  --metadata livy-version=0.7.0

gcloud composer environments create prophecy --location ${REGION} --image-version composer-1.20.10-airflow-2.4.3 --service-account "462580942836-compute@developer.gserviceaccount.com"


gcloud dataproc workflow-templates create prophecy --region=us-central1

gcloud dataproc workflow-templates add-job spark --workflow-template=prophecy --step-id=compute --class=org.apache.spark.examples.SparkPi --jars=file:///usr/lib/spark/examples/jars/spark-examples.jar --region=us-central1 -- 1000
      
gcloud dataproc workflow-templates set-managed-cluster prophecy --cluster-name=prophecy --single-node --region=us-central1

gcloud dataproc workflow-templates describe prophecy --region=us-central1






      


      
      