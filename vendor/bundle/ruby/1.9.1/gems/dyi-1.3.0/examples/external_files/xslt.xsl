<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:svg="http://www.w3.org/2000/svg">
  <xsl:template match="/svg:svg">
    <xsl:copy>
      <xsl:copy-of select="@version"/>
      <xsl:copy-of select="@viewBox"/>
      <xsl:copy-of select="@preserveAspectRatio"/>
      <xsl:attribute name="viewBox">0 0 861 488</xsl:attribute>
      <xsl:attribute name="width">861</xsl:attribute>
      <xsl:attribute name="height">488</xsl:attribute>
      <svg:defs>
        <svg:filter id="effect1" filterUnits="userSpaceOnUse" x="-5" y="-5"
                width="305" height="185">
          <svg:feGaussianBlur in="SourceAlpha" stdDeviation="4" result="blur"/>
          <svg:feOffset in="blur" dx="8" dy="12" result="offsetBlur"/>
          <svg:feMerge>
            <svg:feMergeNode in="offsetBlur"/>
            <svg:feMergeNode in="SourceGraphic"/>
          </svg:feMerge>
        </svg:filter>
        <svg:filter id="effect2" filterUnits="userSpaceOnUse" x="-5" y="-5"
                width="305" height="185">
          <svg:feGaussianBlur in="SourceAlpha" stdDeviation="4" result="blur"/>
          <svg:feOffset in="blur" dx="8" dy="12" result="offsetBlur"/>
          <svg:feSpecularLighting in="blur" surfaceScale="5" specularConstant=".75" 
                  specularExponent="20" lighting-color="#bbbbbb" result="specOut">
            <svg:fePointLight x="-5000" y="-10000" z="20000"/>
          </svg:feSpecularLighting>
          <svg:feComposite in="specOut" in2="SourceAlpha" operator="in" result="specOut"/>
          <svg:feComposite in="SourceGraphic" in2="specOut" operator="arithmetic" 
                  k1="0" k2="1" k3="1" k4="0" result="litPaint"/>
        </svg:filter>
      </svg:defs>
      <svg:g transform="translate(143.5,81.32) scale(2)">
        <xsl:apply-templates mode="normal"/>
      </svg:g>
      <svg:g transform="translate(95.67,162.64)">
        <xsl:apply-templates mode="line"/>
      </svg:g>
      <svg:g transform="translate(478.35,162.64)" filter="url(#effect1)">
        <xsl:apply-templates mode="effect"/>
      </svg:g>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="svg:path" mode="normal">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="svg:path" mode="line">
    <xsl:copy>
      <xsl:copy-of select="@d"/>
      <xsl:attribute name="fill">#fff</xsl:attribute>
      <xsl:attribute name="fill-opacity">0.9</xsl:attribute>
      <xsl:attribute name="stroke">
        <xsl:value-of select="@fill"/>
      </xsl:attribute>
      <xsl:attribute name="stroke-width">2</xsl:attribute>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="svg:path" mode="effect">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="filter">url(#effect2)</xsl:attribute>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
