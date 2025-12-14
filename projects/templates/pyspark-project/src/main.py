from pyspark.sql import SparkSession

def main():
    spark = SparkSession.builder \
        .master("local[*]") \
        .appName("MyApp") \
        .getOrCreate()
    
    data = [(1, "Alice"), (2, "Bob")]
    df = spark.createDataFrame(data, ["id", "name"])
    df.show()
    
    spark.stop()

if __name__ == "__main__":
    main()
