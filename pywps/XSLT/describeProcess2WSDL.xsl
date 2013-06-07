<?xml version="1.0" encoding="UTF-8"?>
<!--
    Author: Author: Jorge de Jesus, http://rsg.pml.ac.uk,jmdj@pml.ac.uk
-->
<!-- License: GPL -->
<!-- ${workspace_loc:/GetCapabilities2WSDL/getCapabilities.xml} -->
<!-- REPLACEME == serverURL  and it needs to be done externaly-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tns="REPLACEME_wsdl"
                xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/"
                xmlns:wps="http://www.opengis.net/wps/1.0.0"
                xmlns:ows="http://www.opengis.net/ows/1.1"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" xmlns:fn="http://pywps.wald.intevation.org/functions"
                xmlns:mime="http://schemas.xmlsoap.org/wsdl/mime/"
                xmlns:soap12="http://schemas.xmlsoap.org/wsdl/soap12/"
                xmlns:ns1="http://org.apache.axis2/xsd/"
                xmlns:wsaw="http://www.w3.org/2006/05/addressing/wsdl/"
                xmlns:http="http://schemas.xmlsoap.org/wsdl/http/"
                version="1.0">

    <xsl:output method="xml" indent="yes" omit-xml-declaration="no" />
    <!-- External variables passed by Python to the XSLT transformer -->
    <xsl:param name="serverURL" />
    <xsl:param name="serverName" />
    <!-- No longer necessary to set serverURL and serverName -->
    <!--
        <xsl:variable name="serverURL"><xsl:value-of
        select="'http://localhost/wps.cgi'"></xsl:value-of></xsl:variable>
    -->
    <!--
        <xsl:variable name="serverName"><xsl:value-of
        select="'PywpsServer'"></xsl:value-of></xsl:variable>
    -->
    <!--  Example of regex with EXSTL -->
    <!--
        <xsl:attribute name="name"><xsl:value-of
        select="concat(regexp:replace(./*[local-name()='Identifier'],'^[^_:A-Za-z]','g',''),'Result')"></xsl:value-of></xsl:attribute>
    -->
    <xsl:template match="/">
        <xsl:element name="wsdl:definitions">
            <!--  Hack, the namespaces are copied from the <stylesheet> element -->
            <xsl:copy-of
                    select="document('')/xsl:stylesheet/namespace::*[name()!='xsl' and name()!='fn']" />
            <xsl:attribute name="targetNamespace">
                <xsl:value-of select="concat($serverURL,'_wsdl')" />
            </xsl:attribute>
            <wsdl:documentation>
            Test PyWPS
            </wsdl:documentation>
            <xsl:element name="wsdl:types">

                <xs:schema  attributeFormDefault="qualified" targetNamespace="http://www.opengis.net/wps/1.0.0">
                    <xsl:for-each select="//*[local-name()='ProcessDescription']">
                        <xsl:call-template name="typeDescribe">
                            <xsl:with-param name="async" select="false()" />
                            <xsl:with-param name="processID"
                                            select="concat('ExecuteProcess_',./*[local-name()='Identifier'])" />
                        </xsl:call-template>
                        <xsl:if
                                test="string(./@storeSupported)='true' and string(./@statusSupported)='true'">
                            <xsl:call-template name="typeDescribe">
                                <xsl:with-param name="async" select="true()" />
                                <xsl:with-param name="processID"
                                                select="concat('ExecuteProcessAsync_',./*[local-name()='Identifier'])" />
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:for-each>
                    <!-- End of DescribeProcess loop for types -->
                    <!-- End of types element -->
                </xs:schema>
            </xsl:element>
            <!-- message sections -->
            <!-- Default WPS request/response messages -->
            <xsl:element name="xs:message">
                <xsl:attribute name="name"> <xsl:value-of select="'ExceptionResponse'" />
                </xsl:attribute>
                <xsl:element name="xs:part">
                    <xsl:attribute name="name"> <xsl:value-of select="'msg'" /> </xsl:attribute>
                    <xsl:attribute name="element"> <xsl:value-of select="'ows:Exception'" /> </xsl:attribute>
                </xsl:element>
            </xsl:element>

            <!-- End of default WPS request/response messages -->
            <!--  Process loop to fetch name -->
            <!--
                Its better to do another loop than one giant loop with everythin
            -->
            <xsl:for-each select="//*[local-name()='ProcessDescription']">
                <xsl:call-template name="messageDescribe">
                    <xsl:with-param name="async" select="false()" />
                    <xsl:with-param name="processID"
                                    select="concat('ExecuteProcess_',./*[local-name()='Identifier'])" />
                </xsl:call-template>
                <xsl:if
                        test="string(./@storeSupported)='true' and string(./@statusSupported)='true'">
                    <xsl:call-template name="messageDescribe">
                        <xsl:with-param name="async" select="true()" />
                        <xsl:with-param name="processID"
                                        select="concat('ExecuteProcessAsync_',./*[local-name()='Identifier'])" />
                    </xsl:call-template>
                </xsl:if>
            </xsl:for-each>
                <!-- End of process description loop for message -->

                <xsl:element name="wsdl:portType">
                    <xsl:attribute name="name">
                        <xsl:value-of select="concat($serverName,'_PortType')" />
                    </xsl:attribute>
                    <xsl:for-each select="//*[local-name()='ProcessDescription']">
                        <xsl:call-template name="operationDescribe">
                            <xsl:with-param name="async" select="false()" />
                            <xsl:with-param name="processID"
                                            select="concat('ExecuteProcess_',./*[local-name()='Identifier'])" />
                        </xsl:call-template>
                        <xsl:if
                                test="string(./@storeSupported)='true' and string(./@statusSupported)='true'">
                            <xsl:call-template name="operationDescribe">
                                <xsl:with-param name="async" select="true()" />
                                <xsl:with-param name="processID"
                                                select="concat('ExecuteProcessAsync_',./*[local-name()='Identifier'])" />
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:for-each>
                    <!--  end of operation -->
                </xsl:element>

            <!-- End of portType -->
            <!-- Start of binding definition -->
            <xsl:element name="wsdl:binding">
                <xsl:attribute name="name">
                    <xsl:value-of select="concat($serverName,'_Binding')" />
                </xsl:attribute>
                <xsl:attribute name="type">
                    <xsl:value-of select="concat('tns:',$serverName,'_PortType')" />
                </xsl:attribute>
                <xsl:element name="soap:binding">
                    <xsl:attribute name="style">
                        <xsl:value-of select="'document'" />
                    </xsl:attribute>
                    <xsl:attribute name="transport">
                        <xsl:value-of select="'http://schemas.xmlsoap.org/soap/http'" />
                    </xsl:attribute>
                </xsl:element>
                <xsl:for-each select="//*[local-name()='ProcessDescription']">
                    <xsl:variable name="processID"
                                  select="concat('ExecuteProcess_',./*[local-name()='Identifier'])" />
                    <!-- Note: variable only exist inside the loop -->
                    <xsl:call-template name="bindingDescribe">
                        <xsl:with-param name="async" select="false()" />
                        <xsl:with-param name="processID"
                                        select="concat('ExecuteProcess_',./*[local-name()='Identifier'])" />
                    </xsl:call-template>
                    <xsl:if
                            test="string(./@storeSupported)='true' and string(./@statusSupported)='true'">
                        <xsl:call-template name="bindingDescribe">
                            <xsl:with-param name="async" select="true()" />
                            <xsl:with-param name="processID"
                                            select="concat('ExecuteProcessAsync_',./*[local-name()='Identifier'])" />
                        </xsl:call-template>
                    </xsl:if>
                </xsl:for-each>
                <!-- End of SOAP operation for each process -->
            </xsl:element>
            <!--End of binding -->
            <!-- service server description -->
            <xsl:element name="wsdl:service">
                <xsl:attribute name="name">
                    <xsl:value-of select="$serverName" />
                </xsl:attribute>
                <xsl:element name="wsdl:port">
                    <xsl:attribute name="name">
                        <xsl:value-of select="concat($serverName,'_Port')" />
                    </xsl:attribute>
                    <xsl:attribute name="binding">
                        <xsl:value-of select="concat('tns:',$serverName,'_Binding')" />
                    </xsl:attribute>
                    <xsl:element name="soap:address"
                                 namespace="http://schemas.xmlsoap.org/wsdl/soap/">
                        <xsl:attribute name="location">
                            <xsl:value-of select="$serverURL" />
                        </xsl:attribute>
                    </xsl:element>
                </xsl:element>
                <!-- end of port element -->
            </xsl:element>
            <!-- end of service element -->
        </xsl:element>
        <!-- End of definitions, end of WSDL -->
    </xsl:template>

    <xsl:template name="typeDescribe">
        <xsl:param name="async" />
        <xsl:param name="processID" />
        <!-- Inputs -->
        <xsl:element name="xs:element">
            <xsl:attribute name="name">
                <xsl:value-of select="$processID" />
            </xsl:attribute>
            <xsl:element name="xs:complexType">
                <xsl:element name="xs:sequence">
                    <!--
                        Getting the Input value: minOccurs, maxOccurs,Identifier, and
                        datatype (LiteralData) from each input
                    -->
                    <xsl:for-each select="./*/*[local-name()='Input']">
                        <xsl:element name="xs:element">
                            <xsl:attribute name="minOccurs">
                                <xsl:value-of select="./@minOccurs" />
                            </xsl:attribute>
                            <xsl:attribute name="maxOccurs">
                                <xsl:value-of select="./@maxOccurs" />
                            </xsl:attribute>
                            <xsl:attribute name="name">
                                <xsl:value-of
                                        select="fn:flagRemover(string(./*[local-name()='Identifier']))" />
                            </xsl:attribute>
                            <!--
                                If to fecth datatype, its not safe to use ows:reference better
                                to get the element value
                            -->
                            <!--  If no dataType then we need to  -->
                            <xsl:if test="./*/*[local-name()='DataType']">
                                <xsl:attribute name="type">
                                    <xsl:value-of
                                            select="concat('xs:',./*/*[local-name()='DataType'])" />
                                </xsl:attribute>
                            </xsl:if>
                        </xsl:element>
                        <!-- End of element inside sequence -->
                    </xsl:for-each>
                    <!-- end of Input loop -->
                </xsl:element>
                <!--  End of sequence -->
            </xsl:element>
            <!-- End of complexType -->
        </xsl:element>
        <!-- End of xsd:schema End of inputs -->
        <!--  Outputs/Response -->
        <xsl:element name="xs:element">
            <!-- Using processID from above -->
            <xsl:attribute name="name">
                <xsl:value-of select="concat($processID,'Response')" />
            </xsl:attribute>
            <xsl:element name="xs:complexType">
                <xsl:element name="xs:sequence">
                    <!--
                        Getting the Ouput value: ,Identifier, and datatype (LiteralData)
                        from each input
                    -->
                    <!-- If we have ascyn process then there is only one result -->
                    <xsl:choose>
                        <xsl:when test="$async">
                            <!-- Element supporting URL -->
                            <xsl:element name="xs:element">
                                <xsl:attribute name="name">
                                    <xsl:value-of select="'statusURLResult'" />
                                </xsl:attribute>
                                <xsl:attribute name="minOccurs">
                                    <xsl:value-of select="'1'" />
                                </xsl:attribute>
                                <xsl:attribute name="maxOccurs">
                                    <xsl:value-of select="'1'" />
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="./*/*[local-name()='Output']">
                                <xsl:element name="xs:element">
                                    <xsl:attribute name="name">
                                        <xsl:value-of
                                                select="concat(fn:flagRemover(string(./*[local-name()='Identifier'])),'Result')" />
                                    </xsl:attribute>
                                    <!--  not certain if a default minOccurs and maxOccurs should be set -->
                                    <xsl:attribute name="minOccurs">
                                        <xsl:value-of select="'1'" />
                                    </xsl:attribute>
                                    <xsl:attribute name="maxOccurs">
                                        <xsl:value-of select="'1'" />
                                    </xsl:attribute>
                                    <xsl:if test="./*/*[local-name()='DataType']">
                                        <xsl:attribute name="type">
                                            <xsl:value-of
                                                    select="concat('xs:',./*/*[local-name()='DataType'])" />
                                        </xsl:attribute>
                                    </xsl:if>
                                    <!--
                                        <xsl:choose> <xsl:when test="./*/*[local-name()='DataType']">
                                        <xsl:attribute name="type"><xsl:value-of
                                        select="concat('xsd:',./*/*[local-name()='DataType'])"></xsl:value-of></xsl:attribute>
                                        </xsl:when> <xsl:otherwise> <xsl:attribute
                                        name="type"><xsl:value-of
                                        select="'wps:anyXMLType'"></xsl:value-of></xsl:attribute>

                                        </xsl:otherwise> </xsl:choose>
                                    -->
                                    <xsl:if test="./*/*[local-name()='DataType']">
                                        <xsl:attribute name="type">
                                            <xsl:value-of
                                                    select="concat('xs:',./*/*[local-name()='DataType'])" />
                                        </xsl:attribute>
                                    </xsl:if>
                                </xsl:element>
                                <!-- response result element -->
                            </xsl:for-each>
                            <!-- End of output loop -->
                        </xsl:otherwise>
                        <!-- End of sync reponse from choose -->
                    </xsl:choose>
                    <!-- end of Async or sync output -->
                </xsl:element>
                <!-- sequence element end -->
            </xsl:element>
            <!-- ComplexType end -->
        </xsl:element>
        <!-- End of elemement with process response name -->
        <!-- adding anyXMLType -->
        <!--
            <complexType name="anyXMLType"
            xmlns="http://www.w3.org/2001/XMLSchema"
            targetNamespace="http://www.opengis.net/wps/1.0.0"> <sequence> <any
            namespace="##any" processContents="lax" minOccurs="1"
            maxOccurs="1"></any> </sequence> </complexType>
        -->
        <!-- End of xsd:schema End of output -->
    </xsl:template>
    <xsl:template name="messageDescribe">
        <xsl:param name="async" />
        <xsl:param name="processID" />
        <!-- request message -->
        <xsl:element name="wsdl:message">
            <xsl:attribute name="name">
                <xsl:value-of select="concat($processID,'Request')" />
            </xsl:attribute>
            <xsl:element name="wsdl:part">
                <xsl:attribute name="name">
                    <xsl:value-of select="'DataInputs'" />
                </xsl:attribute>
                <xsl:attribute name="element">
                    <xsl:value-of select="concat('wps:',$processID)" />
                </xsl:attribute>
            </xsl:element>
        </xsl:element>
        <!--  response message -->
        <xsl:element name="wsdl:message">
            <xsl:attribute name="name">
                <xsl:value-of select="concat($processID,'Response')" />
            </xsl:attribute>
            <xsl:element name="wsdl:part">
                <xsl:attribute name="name">
                    <xsl:value-of select="'ProcessOutputs'" />
                </xsl:attribute>
                <xsl:attribute name="element">
                    <xsl:value-of select="concat('wps:',$processID,'Response')" />
                </xsl:attribute>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template name="operationDescribe">
        <xsl:param name="async" />
        <xsl:param name="processID" />
        <!-- Operation section inside portType -->
        <xsl:element name="wsdl:operation">
            <xsl:attribute name="name">
                <xsl:value-of select="$processID" />
            </xsl:attribute>
            <xsl:element name="wsdl:input">
                <xsl:attribute name="message">
                    <xsl:value-of select="concat('tns:',$processID,'Request')" />
                </xsl:attribute>
            </xsl:element>
            <xsl:element name="wsdl:output">
                <xsl:attribute name="message">
                    <xsl:value-of select="concat('tns:',$processID,'Response')" />
                </xsl:attribute>
            </xsl:element>
            <xsl:element name="wsdl:fault">
                <xsl:attribute name="name">
                    <xsl:value-of select="'ExceptionResponse'" />
                </xsl:attribute>
                <xsl:attribute name="message">
                    <xsl:value-of select="'tns:ExceptionResponse'" />
                </xsl:attribute>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template name="bindingDescribe">
        <xsl:param name="async" />
        <xsl:param name="processID" />
        <xsl:element name="wsdl:operation">
            <xsl:attribute name="name">
                <xsl:value-of select="$processID" />
            </xsl:attribute>
            <xsl:element name="soap:operation">
                <xsl:attribute name="soapAction">
                    <xsl:value-of select="concat($serverURL,'/',$processID)" />
                </xsl:attribute>
                <xsl:attribute name="style">
                    <xsl:value-of select="'document'" />
                </xsl:attribute>
            </xsl:element>
            <xsl:element name="wsdl:input">
                <xsl:element name="soap:body">
                    <xsl:attribute name="use">
                        <xsl:value-of select="'literal'" />
                    </xsl:attribute>
                </xsl:element>
            </xsl:element>
            <!-- end input -->
            <xsl:element name="wsdl:output">
                <xsl:element name="soap:body">
                    <xsl:attribute name="use">
                        <xsl:value-of select="'literal'" />
                    </xsl:attribute>
                </xsl:element>
            </xsl:element>
            <!-- end input -->
            <xsl:element name="wsdl:fault">
                <xsl:element name="soap:fault">
                    <xsl:attribute name="name">
                        <xsl:value-of select="'ExceptionResponse'" />
                    </xsl:attribute>
                    <xsl:attribute name="use">
                        <xsl:value-of select="'literal'" />
                    </xsl:attribute>
                </xsl:element>
            </xsl:element>
            <!-- end input -->
        </xsl:element>
        <!-- end operation  -->
    </xsl:template>
</xsl:stylesheet>