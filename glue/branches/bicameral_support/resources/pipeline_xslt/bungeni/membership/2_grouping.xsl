<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:bdates="http://www.bungeni.org/xml/dates/1.0"
    xmlns:busers="http://www.bungeni.org/xml/users/1.0"
    xmlns:bctypes="http://www.bungeni.org/xml/contenttypes/1.0"    
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:import href="resources/pipeline_xslt/bungeni/common/func_dates.xsl" />
    <xsl:import href="resources/pipeline_xslt/bungeni/common/func_users.xsl" />
    <xsl:import href="resources/pipeline_xslt/bungeni/common/func_content_types.xsl" />    
    <xsl:import href="resources/pipeline_xslt/bungeni/common/include_identity.xsl" />
    <xsl:import href="resources/pipeline_xslt/bungeni/common/include_common.xsl"/>
    <xsl:import href="resources/pipeline_xslt/bungeni/common/include_user_tmpls.xsl"/>
    <xsl:import href="resources/pipeline_xslt/bungeni/common/include_addr_tmpls.xsl"/>
    <xsl:import href="resources/pipeline_xslt/bungeni/common/include_group_tmpls.xsl"/>
    <xsl:import href="resources/pipeline_xslt/bungeni/common/include_memb_tmpls.xsl"/>
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Oct 26, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> anthony</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output indent="yes" method="xml" encoding="UTF-8"/>
    
    <!-- These values are set in first input which is grouping_Level1 -->        
    <xsl:variable name="country-code" select="data(/ontology/bungeni/country)" />
    <xsl:variable name="parliament-election-date" select="data(/ontology/bungeni/parliament/@date)" />
    <xsl:variable name="for-parliament" select="data(/ontology/bungeni/parliament/@href)" />
    <xsl:variable name="parliament-id" select="data(/ontology/bungeni/@id)" />
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="field[@name='combined_name']" />
    <xsl:template match="field[@name='receive_notification']" />
    <xsl:template match="field[@name='_password']" />
    
    <xsl:template match="field[@name='timestamp' or 
        @name='date_active' or 
        @name='date_audit']">
        <xsl:element name="{local-name()}" >
            <xsl:variable name="misc_dates" select="." />
            <xsl:attribute name="name" select="@name" /> 
            <xsl:attribute name="type">xs:dateTime</xsl:attribute>
            <xsl:value-of select="bdates:parse-date($misc_dates)" />
        </xsl:element>
    </xsl:template> 
    
</xsl:stylesheet>