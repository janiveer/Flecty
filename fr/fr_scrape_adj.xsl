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

  <xsl:import href="../Scraper.xsl"/>
  <xsl:param name="link" select="'https://fr.wiktionary.org/wiki'"/>
  <xsl:param name="wiki" select="'http://localhost:8080/wiktionary_fr_all_nopic_2015-11/A'"/>

  <xsl:template match="div" mode="entry">
    <xsl:param name="lemma"/>
    <xsl:apply-templates select="div|h3[span[@id='Adjectif']]" mode="entry">
      <xsl:with-param name="lemma" select="$lemma"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="h3" mode="entry">
    <xsl:param name="lemma"/>
    <xsl:apply-templates select="following::table[contains(@class, 'flextable-fr-mfsp')][1]" mode="entry">
      <xsl:with-param name="lemma" select="$lemma"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="table" mode="entry">
    <xsl:param name="lemma"/>
    <entry xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:attribute name="n">
        <xsl:value-of select="$lemma"/>
      </xsl:attribute>
      <xsl:apply-templates select="descendant::tr" mode="entry"/>
      <link>
        <xsl:attribute name="target">
          <xsl:value-of select="concat($link, '/', $lemma)"/>
        </xsl:attribute>
      </link>
    </entry>
  </xsl:template>

  <xsl:template match="tr[contains(@class, 'flextable-fr-m')]" mode="entry">
    <xsl:apply-templates select="td" mode="declension">
      <xsl:with-param name="gender" select="'m'"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="tr[contains(@class, 'flextable-fr-f')]" mode="entry">
    <xsl:apply-templates select="td" mode="declension">
      <xsl:with-param name="gender" select="'f'"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="tr[not(@class)]" mode="entry">
    <xsl:if test="descendant::strong[@class='selflink'] and not(following-sibling::tr/descendant::strong[@class='selflink'])">
      <xsl:apply-templates select="td" mode="declension">
        <xsl:with-param name="gender" select="'m f'"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>

  <xsl:template match="td[1]" mode="declension">
    <xsl:param name="gender"/>
    <form xmlns="http://www.tei-c.org/ns/1.0">
      <gramGrp>
        <gen>
          <xsl:attribute name="value">
            <xsl:value-of select="$gender"/>
          </xsl:attribute>
        </gen>
        <number>
          <xsl:attribute name="value">
            <xsl:choose>
              <xsl:when test="@colspan='2'">
                <xsl:value-of select="'sg pl'"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'sg'"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </number>
      </gramGrp>
      <orth>
        <xsl:apply-templates select="descendant::strong[@class='selflink']|descendant::a[1]" mode="declension"/>
      </orth>
    </form>
  </xsl:template>

  <xsl:template match="td[2]" mode="declension">
    <xsl:param name="gender"/>
    <form xmlns="http://www.tei-c.org/ns/1.0">
      <gramGrp>
        <gen>
          <xsl:attribute name="value">
            <xsl:value-of select="$gender"/>
          </xsl:attribute>
        </gen>
        <number value="pl"/>
      </gramGrp>
      <orth>
        <xsl:apply-templates select="descendant::strong[@class='selflink']|descendant::a[1]" mode="declension"/>
      </orth>
    </form>
  </xsl:template>

  <xsl:template match="strong|a" mode="declension">
    <xsl:copy-of select="text()"/>
  </xsl:template>

</xsl:stylesheet>
