# JVM Ecosystem

Java setup for Apache Spark and JVM-based data tools.

## Java Installation

```bash
sudo dnf install -y java-21-openjdk-devel
```

## JAVA_HOME Configuration

Dynamic configuration (survives updates):

```bash
echo 'export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))' >> ~/.bashrc
source ~/.bashrc

# Verify
echo $JAVA_HOME
java -version
javac -version
```

## Why Java 21?

- LTS version (Long Term Support)
- Required for Apache Spark 3.4+
- Required for Apache Kafka, Flink
- Modern features and performance
- Well supported

## Verification

```bash
# Java
java -version
javac -version
echo $JAVA_HOME
```

---

## Optional Tools

### Build Tools (Maven/Gradle)

**Only needed if you:**
- Write custom Spark code in Scala/Java
- Build custom Kafka connectors
- Develop Java-based data tools

For most **PySpark-based data engineering**, these are **not required**.

#### Maven

```bash
sudo dnf install -y maven
mvn --version
```

#### Gradle

```bash
# Install SDKMAN first
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Install Gradle
sdk install gradle
```

### Scala

**Only needed if:**
- Writing Spark jobs in Scala (vs PySpark)
- Contributing to Apache projects in Scala

```bash
sudo dnf install -y scala
scala -version
```

---

## What You Actually Need

For **cloud-native data engineering with PySpark**:
- ✅ Java 21 (required for Spark, Kafka)
- ❌ Maven/Gradle (not needed for Python-based work)
- ❌ Scala (not needed unless you prefer Scala over Python)

## Next Steps

- [Data Engineering Tools](06-data-engineering.md)

---

**Status:** ✅ Completed (Java only)
