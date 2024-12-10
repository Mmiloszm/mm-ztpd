<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:template match="/">
        <html>
            <head>
                <title>Zespoły</title>
            </head>
            <body>
                <h1>ZESPOŁY:</h1>
                <ol>
                    <xsl:apply-templates select="ZESPOLY/ROW" mode="list"/>
                </ol>
                <!-- Szczegółowe informacje o zespołach -->
                <div>
                    <xsl:apply-templates select="ZESPOLY/ROW" mode="details"/>
                </div>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="ROW" mode="list">
        <li>
            <a href="#{ID_ZESP}">
                <xsl:value-of select="NAZWA"/>
            </a>
        </li>
    </xsl:template>

    <xsl:template match="ROW" mode="details">
        <h2 id="{ID_ZESP}">
            <xsl:value-of select="NAZWA"/>
        </h2>
        <p>Adres: <xsl:value-of select="ADRES"/></p>
        <xsl:variable name="pracownicy" select="PRACOWNICY/ROW"/>
        <xsl:if test="$pracownicy">
            <table border="1">
                <thead>
                    <tr>
                        <th>Nazwisko</th>
                        <th>Etat</th>
                        <th>Zatrudniony</th>
                        <th>Płaca podstawowa</th>
                        <th>Szef</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:apply-templates select="$pracownicy" mode="employee">
                        <xsl:sort select="NAZWISKO" order="ascending"/>
                    </xsl:apply-templates>
                </tbody>
            </table>
        </xsl:if>
        <p>Liczba pracowników: <xsl:value-of select="count($pracownicy)"/></p>
    </xsl:template>

    <xsl:template match="ROW" mode="employee">
        <tr>
            <td><xsl:value-of select="NAZWISKO"/></td>
            <td><xsl:value-of select="ETAT"/></td>
            <td><xsl:value-of select="ZATRUDNIONY"/></td>
            <td><xsl:value-of select="PLACA_POD"/></td>
            <td>
                <xsl:choose>
                    <xsl:when test="ID_SZEFA">
                        <xsl:value-of select="/ZESPOLY/ROW/PRACOWNICY/ROW[ID_PRAC=current()/ID_SZEFA]/NAZWISKO"/>
                    </xsl:when>
                    <xsl:otherwise>brak</xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>
