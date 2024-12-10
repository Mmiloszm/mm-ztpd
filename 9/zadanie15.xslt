<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml" indent="yes"/>


    <xsl:template match="/">
        <PRACOWNICY>

            <xsl:apply-templates select="//PRACOWNICY/ROW">
                <xsl:sort select="ID_PRAC" data-type="number" order="ascending"/>
            </xsl:apply-templates>
        </PRACOWNICY>
    </xsl:template>

    <xsl:template match="ROW">
        <PRACOWNIK>
            <xsl:attribute name="ID_PRAC">
                <xsl:value-of select="ID_PRAC"/>
            </xsl:attribute>
            <xsl:attribute name="ID_ZESP">
                <xsl:value-of select="ID_ZESP"/>
            </xsl:attribute>
            <xsl:if test="ID_SZEFA">
                <xsl:attribute name="ID_SZEFA">
                    <xsl:value-of select="ID_SZEFA"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="*[not(name()='ID_PRAC' or name()='ID_ZESP' or name()='ID_SZEFA')]"/>
        </PRACOWNIK>
    </xsl:template>
</xsl:stylesheet>
