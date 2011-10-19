<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:an="http://www.akomantoso.org/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs an" version="2.0"><xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet"><xd:desc><xd:p><xd:b>Created on:</xd:b> Oct 5, 2010</xd:p><xd:p><xd:b>Author:</xd:b> ashok</xd:p><xd:p>Present the complete Act </xd:p></xd:desc></xd:doc><xsl:output method="xhtml"/>
    <!-- global variable input parameter --><xsl:param name="pref"/><xsl:param name="actid"/><xsl:key name="k_section" match="tocItem[@level='2']" use="generate-id((preceding-sibling::tocItem[@level='0']|                                                                             preceding-sibling::tocItem[@level='1'])[last()])"/><xsl:key name="k_sectionheading" match="tocItem[@level='1']" use="generate-id(preceding-sibling::tocItem[@level='0'][1])"/><xsl:template match="toc">
        <!-- check if the document has only a section structure i.e. only level = 2 --><div id="arr-of-sections"><span class="toc">Arrangement of Sections</span><xsl:choose><xsl:when test="(count(//tocItem[@level='0']) eq 0 ) and (count(//tocItem[@level='1']) eq  0)"><ul><xsl:apply-templates select="tocItem[@level='2']" mode="k_section"/></ul></xsl:when><xsl:otherwise><ul><xsl:apply-templates select="key('k_section',generate-id())" mode="k_section"/><xsl:apply-templates select="tocItem[@level='0']" mode="k_part"/></ul></xsl:otherwise></xsl:choose></div></xsl:template><xsl:template match="tocItem" mode="k_part"><li><a target="_blank" href="actview?actid={$actid}&amp;pref={$pref}#{$pref}-{substring(@href,2)}"><xsl:value-of select="."/></a><ul><xsl:apply-templates select="key('k_section',generate-id())" mode="k_section"/><xsl:apply-templates select="key('k_sectionheading',generate-id())" mode="k_sectionheading"/></ul></li></xsl:template><xsl:template match="tocItem" mode="k_sectionheading"><li><a target="_blank" href="actview?actid={$actid}&amp;pref={$pref}#{$pref}-{substring(@href,2)}"><xsl:value-of select="."/></a><ul><xsl:apply-templates select="key('k_section',generate-id())" mode="k_section"/></ul></li></xsl:template><xsl:template match="tocItem" mode="k_section"><li><xsl:if test="position() eq last()"><xsl:attribute name="class"><xsl:text>last</xsl:text></xsl:attribute></xsl:if><a target="_blank" href="actview?actid={$actid}&amp;pref={$pref}#{$pref}-{substring(@href,2)}"><xsl:value-of select="."/></a></li></xsl:template></xsl:stylesheet>