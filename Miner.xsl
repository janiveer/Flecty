<?xml version="1.0" encoding="UTF-8"?>

<!--
     Copyright © 2016 Simon Dew.

     This file is part of Flecty.

     Flecty is free software: you can redistribute it and/or modify it under
     the terms of the GNU Lesser General Public License as published by the
     Free Software Foundation, either version 3 of the License, or (at your
     option) any later version.

     Flecty is distributed in the hope that it will be useful, but WITHOUT ANY
     WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
     FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for
     more details.

     You should have received a copy of the GNU Lesser General Public License
     along with Flecty. If not, see http://www.gnu.org/licenses/.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <xsl:output indent="yes" doctype-system="http://java.sun.com/dtd/properties.dtd"/>

  <xsl:template match="properties">
    <xsl:if test="not(entry[@key='NS'])">
      <xsl:message terminate="yes">
        <xsl:text>NS key not found. Are you sure this is an API call file?</xsl:text>
      </xsl:message>
    </xsl:if>
    <xsl:if test="not(entry[@key='API'])">
      <xsl:message terminate="yes">
        <xsl:text>API key not found. Are you sure this is an API call file?</xsl:text>
      </xsl:message>
    </xsl:if>
    <xsl:variable name="ns"     select="entry[@key='NS']"/>
    <xsl:variable name="uri"    select="entry[@key='API']"/>
    <xsl:variable name="result" select="document($uri)"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="comment"/>
      <xsl:apply-templates select="$result/api">
        <xsl:with-param name="ns" select="$ns"/>
        <xsl:with-param name="uri" select="$uri"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="api">
    <xsl:param name="ns"/>
    <xsl:param name="uri"/>
    <xsl:apply-templates select="query">
      <xsl:with-param name="ns" select="$ns"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="continue">
      <xsl:with-param name="ns" select="$ns"/>
      <xsl:with-param name="uri" select="$uri"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="query">
    <xsl:param name="ns"/>
    <xsl:apply-templates select="categorymembers">
      <xsl:with-param name="ns" select="$ns"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="categorymembers">
    <xsl:param name="ns"/>
    <xsl:apply-templates select="cm[@ns=$ns]"/>
  </xsl:template>

  <xsl:template match="cm">
    <xsl:message terminate="no">
      <xsl:value-of select="@title"/>
    </xsl:message>
    <entry>
      <xsl:attribute name="key">
        <xsl:value-of select="@pageid"/>
      </xsl:attribute>
      <xsl:value-of select="@title"/>
    </entry>
  </xsl:template>

  <xsl:template match="continue">
    <xsl:param name="ns"/>
    <xsl:param name="uri"/>
    <xsl:message terminate="no">
      <xsl:value-of select="@cmcontinue"/>
    </xsl:message>
    <xsl:variable name="uri.next" select="concat($uri, '&amp;cmcontinue=', @cmcontinue)"/>
    <xsl:variable name="result.next" select="document($uri.next)"/>
    <xsl:apply-templates select="$result.next/api">
      <xsl:with-param name="ns" select="$ns"/>
      <xsl:with-param name="uri" select="$uri"/>
    </xsl:apply-templates>
  </xsl:template>

</xsl:stylesheet>
