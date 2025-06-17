lazy val commonSettings = Seq(
  version := "0.0.1",
  organization := "uk.gov.ons",
  scalaVersion := "2.13.14",
  // use 2.13.14 for serverless, 2.12.18 for servered Dataproc
  assembly / test := {}
)

val json4sVersion = "3.7.0-M5"
lazy val buildSettings = Seq(
  name := "ons-ai-batch",
  assembly / mainClass := Some("uk.gov.ons.addressindex.Main"),
  libraryDependencies ++= Seq(
    "org.apache.spark" %% "spark-core" % "3.5.1",
    "org.apache.spark" %% "spark-sql" % "3.5.1",
    "org.json4s" %% "json4s-core" % json4sVersion,
    "org.json4s" %% "json4s-native" % json4sVersion,
    "org.json4s" %% "json4s-jackson" % json4sVersion,
    "org.apache.logging.log4j" % "log4j-api" % "2.20.0",
    "org.apache.logging.log4j" % "log4j-core" % "2.20.0",
    "org.apache.logging.log4j" % "log4j-slf4j-impl" % "2.20.0",
    "commons-lang" % "commons-lang" % "2.6"
  ),
  assembly / assemblyMergeStrategy := {
    case "reference.conf" => MergeStrategy.concat
    case "module-info.class" => MergeStrategy.discard
    case PathList("META-INF", "services", "org.apache.hadoop.fs.FileSystem") => MergeStrategy.filterDistinctLines
    case PathList("META-INF", _*) => MergeStrategy.discard
    case _ => MergeStrategy.first
  }
)

lazy val `address-index-batch` = project.in(file("batch")).settings(commonSettings ++ buildSettings: _*)

