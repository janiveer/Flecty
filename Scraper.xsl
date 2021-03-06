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
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:date="http://exslt.org/dates-and-times"
                extension-element-prefixes="date"
                exclude-result-prefixes="tei date"
                version="1.0">

  <xsl:output indent="yes"/>
  <xsl:param name="wiki" select="'https://en.wiktionary.org/wiki'"/>
  <xsl:param name="link" select="'https://en.wiktionary.org/wiki'"/>
  <xsl:param name="ext" select="''"/>

  <xsl:template match="properties">
    <xsl:if test="entry[@key='NS']">
      <xsl:message terminate="yes">
        <xsl:text>NS key found. Are you sure this is a word list file?</xsl:text>
      </xsl:message>
    </xsl:if>
    <xsl:if test="entry[@key='API']">
      <xsl:message terminate="yes">
        <xsl:text>API key found. Are you sure this is a word list file?</xsl:text>
      </xsl:message>
    </xsl:if>
    <TEI xmlns="http://www.tei-c.org/ns/1.0" version="5.0">
      <teiHeader>
        <fileDesc>
          <titleStmt>
            <title>
              <xsl:apply-templates select="comment"/>
            </title>
            <author>Wiktionary authors</author>
            <editor>Wiktionary editors</editor>
          </titleStmt>
          <editionStmt>
            <edition>
              <date>
                <xsl:value-of select="date:date()"/>
              </date>
              <time>
                <xsl:value-of select="date:time()"/>
              </time>
            </edition>
          </editionStmt>
          <publicationStmt>
            <distributor>
              <link target="https://janiveer.github.io/flecty"/>
            </distributor>
            <availability status="restricted">
              <licence target="http://creativecommons.org/licenses/by-sa/3.0/">CC BY-SA 3.0</licence>
            </availability>
          </publicationStmt>
          <notesStmt>
            <note>
              <title>DISCLAIMER</title>
              <p>The linguistic data in this file is not guaranteed to be accurate or complete.</p>
            </note>
            <note>
              <title>Acknowledgements</title>
              <p>Thanks to the contributors and editors of Wiktionary for the linguistic data. Each entry within this dictionary contains a link back to the Wiktionary page from which the linguistic data was mined. Please see those linked Wiktionary pages for details of the authors who wrote and edited the original data.</p>
            </note>
          </notesStmt>
          <sourceDesc>
            <bibl>
              <link>
                <xsl:attribute name="target">
                  <xsl:value-of select="$link"/>
                </xsl:attribute>
              </link>
            </bibl>
          </sourceDesc>
        </fileDesc>
      </teiHeader>
      <text>
        <body>
          <xsl:apply-templates select="entry"/>
        </body>
      </text>
    </TEI>
  </xsl:template>

  <xsl:template match="comment">
    <xsl:copy-of select="text()"/>
  </xsl:template>

  <xsl:template match="entry">
    <xsl:variable name="lemma" select="text()"/>
    <xsl:variable name="uri" select="concat($wiki, '/', $lemma, $ext)"/>
    <xsl:variable name="result" select="document($uri)"/>
    <xsl:message terminate="no">
      <xsl:value-of select="$lemma"/>
    </xsl:message>
    <xsl:apply-templates select="$result//body">
      <xsl:with-param name="lemma" select="$lemma"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="body">
    <xsl:param name="lemma"/>
    <xsl:apply-templates select="div" mode="entry">
      <xsl:with-param name="lemma" select="$lemma"/>
    </xsl:apply-templates>
  </xsl:template>

</xsl:stylesheet>
