<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:pom="http://maven.apache.org/POM/4.0.0">
	<xsl:output method="xml" indent="yes" />
	<xsl:strip-space elements="*" />
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
	<xsl:template match="pom:plugin[pom:artifactId='maven-shade-plugin']" />
	<xsl:template match="pom:plugin[pom:artifactId='maven-surefire-plugin']" />
	<xsl:template match="pom:plugin[pom:artifactId='lifecycle-mapping']" />
  <xsl:template match="pom:reporting" />
</xsl:stylesheet>