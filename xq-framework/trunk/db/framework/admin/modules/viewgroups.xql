xquery version "3.0";

module namespace viewgrps="http://exist.bungeni.org/viewgroups";
declare namespace xhtml="http://www.w3.org/1999/xhtml" ;
declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace ev="http://www.w3.org/2001/xml-events" ;
declare namespace bf="http://betterform.sourceforge.net/xforms" ;
declare namespace bu="http://portal.bungeni.org/1.0/";
declare namespace i18n="http://exist-db.org/xquery/i18n";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace appconfig = "http://exist-db.org/apps/frameworkadmin/appconfig" at "appconfig.xqm";
import module namespace config = "http://exist-db.org/apps/frameworkadmin/config" at "config.xqm";
import module namespace functx = "http://www.functx.com" at "functx.xqm";

declare variable $viewgrps:CXT := request:get-context-path();
declare variable $viewgrps:REST-CXT-APP :=  $viewgrps:CXT || $appconfig:REST-APP-ROOT;
declare variable $viewgrps:REST-FW-ROOT :=  $viewgrps:CXT || $appconfig:REST-FRAMEWORK-ROOT;


declare variable $viewgrps:MENU := xs:string(request:get-parameter("menu","views"));
declare variable $viewgrps:VIEWS := xs:string(request:get-parameter("views",""));
declare variable $viewgrps:VIEWID := xs:string(request:get-parameter("viewid",""));
declare variable $viewgrps:I18N := xs:string(request:get-parameter("i18n",""));
declare variable $viewgrps:CHAMBER-TYPE := xs:string(request:get-parameter("type","lower_house"));
declare variable $viewgrps:MAINNAV := xs:string(request:get-parameter("mainnav","business"));
declare variable $viewgrps:SUBMENU := xs:string(request:get-parameter("submenu",""));

(:~
 : This is a sample templating function. It will be called by the templating module if
 : it encounters an HTML element with a class attribute: class="app:test". The function
 : has to take exactly 3 parameters.
 : 
 : @param $node the HTML node with the class attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function viewgrps:test($node as node(), $model as map(*)) {
    <p>Template output generated by function app:test at {current-dateTime()}.</p>
};

declare function viewgrps:local-catalogues() {

 for $catalogue in collection($appconfig:I18N-ROOT)/catalogue[@source="local"]
 return
    $catalogue

};

declare function viewgrps:views($node as node(), $model as map(*)) {

    <ul class="unstyled">
        {
            for $view in doc($appconfig:CONFIG-FILE)/ui/viewgroups/views[@name eq $viewgrps:VIEWS]/view
            return
                <li><a href="view.html?menu={$viewgrps:MENU}&amp;views={$viewgrps:VIEWS}&amp;viewid={data($view/@id)}">{data($view/@path)}</a></li>                
        }
        <li>
            <span class="label label-info">
                <i class="icon icon-plus icon-white"></i>
                <a href="view-add.html?menu={$viewgrps:MENU}&amp;views={$viewgrps:VIEWS}&amp;viewid=new_view">Add View</a>
            </span>
        </li>
    </ul>    
};

declare function local:eXide-link() as node()* 
{
    for $view in doc($appconfig:CONFIG-FILE)/ui/viewgroups/views[@name eq $viewgrps:VIEWS]/view[@id eq $viewgrps:VIEWID]
    let $href := "index.html"
    let $link := templates:link-to-app("http://exist-db.org/apps/eXide", "index.html?open=" || $appconfig:BUNGENI-ROOT || "/" || $view/xsl/text())
    return
        element span {
            "click ",
            element a {
                attribute class { "btn btn-small" },
                attribute href { $link },
                attribute target { "_new" },
                "here "
            },
            " to edit ",
            element code { 
                $view/xsl/text()
            },
            " XSL template on eXide."
        }
};


declare 
function viewgrps:view-add($node as node(), $model as map(*)) {

    let $contextPath := request:get-context-path()
    return
        <div xmlns:i18n="http://exist-db.org/xquery/i18n">
            <xf:model>
                <xf:instance id="i-uiconfig" src="{$viewgrps:CXT || $appconfig:REST-UI-CONFIG}"/>
                
                <xf:instance id="i-view" src="{$viewgrps:REST-CXT-APP}/model_templates/view.xml"/>
                
                <xf:instance id="i-controller" src="{$viewgrps:REST-CXT-APP}/model_templates/controller.xml"/>
                
                <xf:instance id="i-tags" src="{$viewgrps:REST-CXT-APP}/model_templates/tags.xml"/>
                
                <xf:instance id="tmp" src="{$viewgrps:REST-CXT-APP}/model_templates/tmp.xml"/>
                
                <xf:bind nodeset="instance()/viewgroups/views[@name eq '{$viewgrps:VIEWS}']/view[last()]">
                    <xf:bind id="viewid" nodeset="@id" type="xf:string" constraint="string-length(.) &gt; 2 and matches(., '^[a-z_]+$') and count(instance()/viewgroups/views[@name eq '{$viewgrps:VIEWS}']/view/@id) eq count(distinct-values(instance()/viewgroups/views[@name eq '{$viewgrps:VIEWS}']/view/@id))"/>
                    <xf:bind id="viewtag" nodeset="@tag" type="xf:string" required="true()"/>
                    <xf:bind id="viewpath" nodeset="@path" type="xf:string"/>
                    <xf:bind id="viewcheckfor" nodeset="@check-for" type="xf:string"/>
                    <xf:bind id="viewi18nkey" nodeset="title/i18n:text/@key" type="xf:string" required="true()"/>                    
                    <xf:bind id="viewi18ntitle" nodeset="title/i18n:text" type="xf:string" required="true()"/>
                    <xf:bind id="viewxsl" nodeset="xsl" type="xf:string"/>
                </xf:bind>
                
                <xf:submission id="s-add" method="put" replace="none" ref="instance()">
                    <xf:resource value="'{$viewgrps:CXT || $appconfig:REST-UI-CONFIG}'"/>
                    
                    <xf:header>
                        <xf:name>username</xf:name>
                        <xf:value>{$appconfig:admin-username}</xf:value>
                    </xf:header>
                    <xf:header>
                        <xf:name>password</xf:name>
                        <xf:value>{$appconfig:admin-password}</xf:value>
                    </xf:header>
                    <xf:header>
                        <xf:name>realm</xf:name>
                        <xf:value>exist</xf:value>
                    </xf:header>
                    
                    <xf:action ev:event="xforms-submit-done">
                        <xf:message level="ephemeral">view details added successfully</xf:message>
                    </xf:action>
                    
                    <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                        <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                        <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                    </xf:action>
                    
                    <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                        <xf:message>The form details have not been filled in correctly</xf:message>
                    </xf:action>
                </xf:submission>    

                <xf:action ev:event="xforms-ready">
                    <xf:action if="exists(instance()/viewgroups/views/view)">
                        <!-- Inject the new view at the end of this views -->
                        <xf:insert nodeset="instance()/viewgroups/views[@name eq '{$viewgrps:VIEWS}']/view" at="last()" position="after" origin="instance('i-view')/view" />
                    </xf:action>                
                    <xf:setfocus control="path-name"/>
                    <xf:setvalue ref="instance()/viewgroups/views[@name eq '{$viewgrps:VIEWS}']/view[last()]/@path" value="concat('{lower-case($viewgrps:VIEWS)}','-')"/>
                </xf:action>        
            </xf:model>
            <div class="spacedHorizontal formWrapper">
                <div class="viewTitle">
                    <h2>{$viewgrps:VIEWS}&#160;{$viewgrps:VIEWID}</h2>
                    <ul class="nav nav-tabs">
                      <li class="active"><a href="#">Properties</a></li>
                    </ul>
                </div>
                <xf:group appearance="bf:horizontalTable" ref="instance()/viewgroups/views[@name eq '{$viewgrps:VIEWS}']/view[last()]">
                    <xf:group appearance="bf:verticalTable">  
                        <xf:label>View Properties</xf:label>
                        <xf:input bind="viewid" id="path-id" incremental="true">
                            <xf:label>view id:</xf:label>
                            <xf:hint>unique ID for this view</xf:hint>
                            <xf:alert>invalid ID - duplicate / non-alphabet encountered</xf:alert>
                        </xf:input>                    
                        <xf:select1 id="c-tag" bind="viewtag" appearance="minimal" class="xsmallWidth" incremental="true">
                            <xf:label>tag</xf:label>
                            <xf:hint>either tab when viewing the content of the document OR menu listing</xf:hint>
                            <xf:help>listing item?</xf:help>
                            <xf:alert>invalid</xf:alert>
                            <xf:itemset nodeset="instance('i-tags')/tags/tag">
                                <xf:label ref="@name"></xf:label>
                                <xf:value ref="."></xf:value>
                            </xf:itemset>
                        </xf:select1>                        
                        <xf:input bind="viewpath" id="path-name" incremental="true">
                            <xf:label>path:</xf:label>
                            <xf:hint>Used in menus</xf:hint>
                            <xf:alert>invalid label - non-alphabets disallowed</xf:alert>
                        </xf:input>
                        <xf:textarea bind="viewcheckfor" incremental="true">
                            <xf:label>check-for:</xf:label>
                            <xf:hint>XPath axis as a condition for showing this tab</xf:hint>
                            <xf:help>help for textarea1</xf:help>
                            <xf:alert>invalid</xf:alert>
                        </xf:textarea>                        
                        <xf:select1 class="choiceInput" id="c-xsl" bind="viewxsl" appearance="minimal" incremental="true" selection="open">
                            <xf:label>XSL template:</xf:label>
                            <xf:hint>clone from existing or start from scratch</xf:hint>
                            <xf:help>listing item?</xf:help>
                            <xf:alert>invalid</xf:alert>
                            <xf:itemset nodeset="instance()/viewgroups/views[@name eq '{$viewgrps:VIEWS}']/view/xsl[string-length(.) > 1]">
                                <xf:label ref="."/>
                                <xf:value ref="."></xf:value>
                            </xf:itemset>
                        </xf:select1>     
                        <xf:group appearance="bf:horizontalTable">
                            <xf:trigger>
                                <xf:label>save</xf:label>
                                <xf:action>
                                    <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                    <xf:send submission="s-add"/>
                                </xf:action>                           
                            </xf:trigger>                       
                        </xf:group>                        
                    </xf:group>
                    <xf:group appearance="bf:verticalTable">
                        <xf:label>i18n Catalogues</xf:label>
                        <xf:input bind="viewi18nkey" incremental="true">
                            <xf:label>key:</xf:label>
                            <xf:hint>this is key for retrieving the i18n title of the active language</xf:hint>
                            <xf:help>this is key for retrieving the i18n title of the active language</xf:help>
                            <xf:alert>invalid key</xf:alert>
                        </xf:input>                        
                        <xf:input bind="viewi18ntitle" incremental="true">
                            <xf:label>title:</xf:label>
                            <xf:hint>this is default title used if no translation is available in the active language</xf:hint>
                            <xf:alert>invalid title</xf:alert>
                        </xf:input>  
                    </xf:group>                    
                    <hr/>
                </xf:group>
                {local:eXide-link()}
            </div>
        </div>
};

declare 
function viewgrps:view-edit($node as node(), $model as map(*)) {

    let $contextPath := request:get-context-path()
    let $i18n := data(doc($appconfig:CONFIG-FILE)/ui/viewgroups/views[@name eq $viewgrps:VIEWS]/view[@id eq $viewgrps:VIEWID]/title/i18n:text/@key)
    return
        <div xmlns:i18n="http://exist-db.org/xquery/i18n">
            <xf:model>
                <xf:instance id="i-uiconfig" src="{$viewgrps:CXT || $appconfig:REST-UI-CONFIG}"/>
                
                <xf:instance id="i-controller" src="{$viewgrps:REST-CXT-APP}/model_templates/controller.xml"/>
                
                <xf:instance id="i-tags" src="{$viewgrps:REST-CXT-APP}/model_templates/tags.xml"/>
                
                <xf:instance id="tmp" src="{$viewgrps:REST-CXT-APP}/model_templates/tmp.xml"/>
                
                <xf:bind nodeset="instance()/viewgroups/views[@name eq '{$viewgrps:VIEWS}']/view[@id eq '{$viewgrps:VIEWID}']">
                    <xf:bind id="viewid" nodeset="@id" type="xf:string" required="true()"/>
                    <xf:bind id="viewtag" nodeset="@tag" type="xf:string" required="true()"/>
                    <xf:bind id="viewpath" nodeset="@path" type="xf:string"/>
                    <xf:bind id="viewkey" nodeset="title/i18n:text/@key" type="xf:string"/>
                    <xf:bind id="viewtitle" nodeset="title/i18n:text" type="xf:string"/>
                    <xf:bind id="viewxsl" nodeset="xsl" type="xf:string"/>
                </xf:bind>
                
                <xf:submission id="s-add" method="put" replace="none" ref="instance()">
                    <xf:resource value="'{$viewgrps:CXT || $appconfig:REST-UI-CONFIG}'"/>
                    
                    <xf:header>
                        <xf:name>username</xf:name>
                        <xf:value>{$appconfig:admin-username}</xf:value>
                    </xf:header>
                    <xf:header>
                        <xf:name>password</xf:name>
                        <xf:value>{$appconfig:admin-password}</xf:value>
                    </xf:header>
                    <xf:header>
                        <xf:name>realm</xf:name>
                        <xf:value>exist</xf:value>
                    </xf:header>
                    
                    <xf:action ev:event="xforms-submit-done">
                        <xf:message level="ephemeral">view details saved successfully</xf:message>
                    </xf:action>
                    
                    <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                        <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                        <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                    </xf:action>
                    
                    <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                        <xf:message>The form details have not been filled in correctly</xf:message>
                    </xf:action>
                </xf:submission>    
                
                <xf:submission id="s-delete" method="put" replace="none" ref="instance()">
                    <xf:resource value="'{$viewgrps:CXT || $appconfig:REST-UI-CONFIG}'"/>

                    <xf:header>
                        <xf:name>username</xf:name>
                        <xf:value>{$appconfig:admin-username}</xf:value>
                    </xf:header>
                    <xf:header>
                        <xf:name>password</xf:name>
                        <xf:value>{$appconfig:admin-password}</xf:value>
                    </xf:header>
                    <xf:header>
                        <xf:name>realm</xf:name>
                        <xf:value>exist</xf:value>
                    </xf:header>
                    
                    <xf:action ev:event="xforms-submit-done">
                        <xf:message level="ephemeral">Type deleted successfully</xf:message>
                        <script type="text/javascript">
                            document.location.href = 'views.html?menu={$viewgrps:MENU}&#38;amp;views={$viewgrps:VIEWS}';
                        </script> 
                    </xf:action>

                    <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='true'">
                        <xf:setvalue ref="instance('i-controller')/error/@hasError" value="'true'"/>
                        <xf:setvalue ref="instance('i-controller')/error" value="event('response-reason-phrase')"/>
                    </xf:action>

                    <xf:action ev:event="xforms-submit-error" if="instance('i-controller')/error/@hasError='false'">
                        <xf:message>Transition information have not been filled in correctly</xf:message>
                    </xf:action>
                </xf:submission>                
                
                <xf:action ev:event="xforms-ready">
                    <xf:setfocus control="path-name"/>
                </xf:action>        
            </xf:model>
            <div class="formWrapper">
                <div class="viewTitle">
                    <h2>{$viewgrps:VIEWS}&#160;{$viewgrps:VIEWID}</h2>
                    <ul class="nav nav-tabs">
                      <li class="active"><a href="#">Properties</a></li>
                      <li><a href="view-xsl.html?menu={$viewgrps:MENU}&amp;views={$viewgrps:VIEWS}&amp;viewid={$viewgrps:VIEWID}">XSL Template</a></li>
                      <li><a href="view-i18n.html?menu={$viewgrps:MENU}&amp;views={$viewgrps:VIEWS}&amp;viewid={$viewgrps:VIEWID}&amp;i18n={$i18n}">i18n</a></li>
                    </ul>
                </div>
                <xf:group appearance="compact" ref="instance()/viewgroups/views[@name eq '{$viewgrps:VIEWS}']/view[@id eq '{$viewgrps:VIEWID}']">
                    <xf:group appearance="bf:verticalTable">   
                        <xf:select1 id="c-tag" bind="viewtag" appearance="minimal" incremental="true">
                            <xf:label>tag:</xf:label>
                            <xf:hint>either tab when viewing the content of the document OR menu listing</xf:hint>
                            <xf:help>listing item?</xf:help>
                            <xf:alert>invalid</xf:alert>
                            <xf:itemset nodeset="instance('i-tags')/tags/tag">
                                <xf:label ref="@name"></xf:label>
                                <xf:value ref="."></xf:value>
                            </xf:itemset>
                        </xf:select1>                        
                        <xf:input bind="viewpath" id="path-name" incremental="true">
                            <xf:label>path:</xf:label>
                            <xf:hint>Used in menus</xf:hint>
                            <xf:alert>invalid label - non-alphabets disallowed</xf:alert>
                        </xf:input>
                        <xf:output bind="viewkey" incremental="true">
                            <xf:hint>this is default title used if no translation is available in the active language</xf:hint>
                            <xf:alert>invalid title</xf:alert>
                        </xf:output>                          
                        <xf:input bind="viewtitle" incremental="true">
                            <xf:label>title:</xf:label>
                            <xf:hint>this is default title used if no translation is available in the active language</xf:hint>
                            <xf:alert>invalid title</xf:alert>
                        </xf:input>                    
                    </xf:group>
                    <hr/>
                    <xf:group appearance="bf:horizontalTable">
                        <xf:trigger>
                            <xf:label>update</xf:label>
                            <xf:action>
                                <xf:setvalue ref="instance('tmp')/wantsToClose" value="'true'"/>
                                <xf:send submission="s-add"/>
                            </xf:action>                           
                        </xf:trigger>
                        
                        <xf:group appearance="bf:verticalTable">                      
                             <xf:switch>
                                <xf:case id="delete">
                                   <xf:trigger ref="instance()/viewgroups/views[@name eq '{$viewgrps:VIEWS}']">
                                      <xf:label>delete</xf:label>
                                      <xf:action ev:event="DOMActivate">
                                         <xf:toggle case="confirm" />
                                      </xf:action>
                                   </xf:trigger>
                                </xf:case>
                                <xf:case id="confirm">
                                   <h2>Are you sure you want to delete this view?</h2>
                                   <xf:group appearance="bf:horizontalTable">
                                       <xf:trigger>
                                          <xf:label>Delete</xf:label>
                                          <xf:action ev:event="DOMActivate">
                                            <xf:delete nodeset="instance()/viewgroups/views[data(@name) eq '{$viewgrps:VIEWS}']/view[data(@id) eq '{$viewgrps:VIEWID}']"/>
                                            <xf:send submission="s-delete"/>
                                            <xf:toggle case="delete" />
                                          </xf:action>
                                       </xf:trigger>
                                       <xf:trigger>
                                            <xf:label>Cancel</xf:label>
                                            <xf:toggle case="delete" ev:event="DOMActivate" />
                                       </xf:trigger>
                                    </xf:group>
                                </xf:case>
                             </xf:switch>   
                        </xf:group>                        
                    </xf:group>
                    <hr/>         
                    {local:eXide-link()}  
                    <hr/>                    
                </xf:group>
            </div>
        </div>
};

declare 
function viewgrps:view-i18n($node as node(), $model as map(*)) {

    let $contextPath := request:get-context-path()
    return
        <div xmlns:i18n="http://exist-db.org/xquery/i18n">
            <div class="formWrapper">
                <div class="viewTitle">
                    <h2>{$viewgrps:VIEWS}&#160;{$viewgrps:VIEWID}</h2>
                    <ul class="nav nav-tabs">
                      <li><a href="view.html?menu={$viewgrps:MENU}&amp;views={$viewgrps:VIEWS}&amp;viewid={$viewgrps:VIEWID}">Properties</a></li>
                      <li><a href="view-xsl.html?menu={$viewgrps:MENU}&amp;views={$viewgrps:VIEWS}&amp;viewid={$viewgrps:VIEWID}">XSL Template</a></li>
                      <li class="active"><a href="#">i18n</a></li>
                    </ul>
                </div>
                <div class="form-witheld">
                    <h2>translations for "{$viewgrps:VIEWID}"</h2>
                    <dl class="dl-horizontal">
                    {
                        for $language in doc($appconfig:LANG-FILE)/languages/language
                        let $cata-lang := doc($appconfig:I18N-ROOT || "/collection_" || data($language/@id)  || ".xml")/catalogue/msg[@key eq $viewgrps:I18N]
                        let $translated := if(string-length($cata-lang) > 1) then $cata-lang else <code>None</code>
                        return 
                            <span>
                                <dt>{data($language/@english-name)}</dt>
                                <dd>
                                    {$translated}&#160;
                                    <a href=""><i class="icon-edit"></i></a>                            
                                </dd>
                            </span>
                    }
                    </dl>
                </div>
            </div>
        </div>
};