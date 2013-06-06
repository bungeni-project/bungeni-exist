xquery version "3.0";

module namespace app="http://exist-db.org/apps/configmanager/templates";
declare namespace xhtml="http://www.w3.org/1999/xhtml" ;
declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace ev="http://www.w3.org/2001/xml-events" ;
declare namespace bf="http://betterform.sourceforge.net/xforms" ;


import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace appconfig = "http://exist-db.org/apps/configmanager/config" at "appconfig.xqm";
import module namespace config = "http://exist-db.org/xquery/apps/config" at "config.xqm";

declare variable $app:CXT := request:get-context-path();
declare variable $app:REST-CXT-APP :=  $app:CXT || $appconfig:REST-APP-ROOT;
declare variable $app:REST-BC-LIVE :=  $app:CXT || $appconfig:REST-BUNGENI-CUSTOM-LIVE;

(:~
 : This is a sample templating function. It will be called by the templating module if
 : it encounters an HTML element with a class attribute: class="app:test". The function
 : has to take exactly 3 parameters.
 : 
 : @param $node the HTML node with the class attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare 
%templates:wrap 
function app:test($node as node(), $model as map(*)) {
    <p>Dummy template output generated by function app:test at {current-dateTime()}. The templating
        function was triggered by the class attribute <code>class="app:test"</code>.</p>
};

declare 
    %templates:default("active", "search") 
function app:get-main-nav($node as node(), $model as map(*), $active as xs:string) {
    (: timestamp appended to page links to prevent caching :)
    let $timestamp := current-time()
    return 
    <div id="navigation">
        <ul class="dropdown dropdown-horizontal">
            <li class="barren">
                <span>&#160;&#187;&#187;&#160;&#187;&#187;</span>
            </li>
            <li class="barren"><a href="roles.html"><span>roles</span></a></li>            
            <li class="barren"><a href="types.html"><span>types</span></a></li>
            <li class="barren"><a href="vocabularies.html"><span>vocabularies</span></a></li>
            <li class="show"><a href="#config"><span>upload/save</span></a>
                <ul class="dropdown">
                    <li><a id="show-popup" href="upload.html?t={$timestamp}">upload</a></li>
                    <li class="last"><a class="confirm-delete" title="commit all your changes back to bungeni" href="save.html?t={$timestamp}">commit</a></li>
                </ul>
            </li>
        </ul>
    </div>
};

declare 
    %templates:default("active", "form") 
function app:get-secondary-menu($node as node(), $model as map(*), $active as xs:string) {
    <div id="secondary-menu">
        <!--ul class="secondary">
            <li><a href="#">add new type</a></li>
        </ul-->
    </div>
};

declare 
    %templates:default("primary", "types")
    %templates:default("secondary", "form")
    %templates:default("tmpl", "")
    %templates:default("eol", "edit")
    %templates:default("level", 3)
function app:breadcrumb($node as node(), $model as map(*), 
    $primary as xs:string,
    $secondary as xs:string,
    $tmpl as xs:string,
    $eol as xs:string,
    $level as xs:integer) {

    let $type := request:get-parameter("type", "none")
    (: Types = doc.xml, Roles = <role/>  :)
    let $name := request:get-parameter("doc", "none")
    let $pos := xs:integer(request:get-parameter("pos", 0))    
    let $d := doc($appconfig:TYPES-XML)/types
    let $flattened := <grouped>{appconfig:flatten($d)}</grouped>            
    let $typename := data(appconfig:three-in-one($flattened)/archetype[@key eq $type]/child::*[$pos]/@name)    
    return
        <p id="breadcrumb">
            <a href="{$primary}.html">{$primary}</a>
            <a href="{$secondary}.html?type={$type}&amp;doc={$name}&amp;pos={$pos}">{$name}</a>
            {
                if($level > 2) then 
                    <a href="{$tmpl}.html?type={$type}&amp;doc={$name}&amp;pos={$pos}">{$tmpl}</a>
                else
                    ()
            }
            <span class="eol">{$eol}</span>
        </p>  
};

declare 
    %templates:default("active", "")
function app:get-type-parts($node as node(), $model as map(*), $active as xs:string) {
    
    <div id="secondary-menu"> 
        <ul class="secondary"> 
            {
            let $type := request:get-parameter("type", "none")
            let $name := request:get-parameter("doc", "none")
            let $pos := xs:integer(request:get-parameter("pos", 0))            
            
            for $part in ('form', 'workflow', 'workspace', 'notification')
            return 
                switch ($part)
                    case 'form' return 
                        let $doc-path := $appconfig:CONFIGS-FOLDER || "/forms/" || $name || ".xml"
                        return 
                            if (doc-available($doc-path) or $active eq $part) then 
                                <li><a class="sec-active" href="{$part}.html?type={$type}&amp;doc={$name}&amp;pos={$pos}"><i class="icon-edit add"></i>&#160;{$part}</a></li>
                            else 
                                <li><a class=" {$doc-path}" href="{$part}.html?type={$type}&amp;doc={$name}&amp;pos={$pos}&amp;init=true"><i class="icon-plus add"></i> add {$part}</a></li>
                        
                    case 'workflow' return 
                        let $doc-path := $appconfig:CONFIGS-FOLDER || "/workflows/" || $name || ".xml"
                        return 
                            if (doc-available($doc-path) or $active eq $part) then
                                <li><a class="sec-active" href="{$part}.html?type={$type}&amp;doc={$name}&amp;pos={$pos}"><i class="icon-edit add"></i>&#160;{$part}</a></li>
                            else 
                                <li><a href="{$part}.html?type={$type}&amp;doc={$name}&amp;pos={$pos}&amp;init=true"><i class="icon-plus add"></i> add {$part}</a></li>
                    case 'workspace' return 
                        let $doc-path := $appconfig:CONFIGS-FOLDER || "/workspace/" || $name || ".xml"
                        return 
                            if (doc-available($doc-path) or $active eq $part) then
                                <li><a class="sec-active" href="{$part}.html?type={$type}&amp;doc={$name}&amp;pos={$pos}"><i class="icon-edit add"></i>&#160;{$part}</a></li>
                            else
                                <li><a href="{$part}.html?type={$type}&amp;doc={$name}&amp;pos={$pos}&amp;init=true"><i class="icon-plus add"></i> add {$part}</a></li>
                    (:                                
                    case 'notification' return 
                        let $doc-path := $appconfig:CONFIGS-FOLDER || "/notifications/" || $name || ".xml"
                        return 
                            if (doc-available($doc-path) or $active eq $part) then 
                                <li><a class="sec-active" href="{$part}.html?type={$type}&amp;doc={$name}&amp;pos={$pos}"><i class="icon-edit add"></i>&#160;{$part}</a></li>
                            else 
                                <li><a href="{$part}.html?type={$type}&amp;doc={$name}&amp;pos={$pos}&amp;init=true"><i class="icon-plus add"></i> add {$part}</a></li>                         
                   :)
                   default return ()
                   
            }
        </ul> 
    </div>
};

declare 
    %templates:default("active", "")
function app:get-action-state($node as node(), $model as map(*), $active as xs:string) {
    
    <div id="secondary-menu">
        default
    </div>
};


declare function app:xforms-declare($node as node(), $model as map(*)) {
     let $CXT := request:get-context-path()
     let $REST-CXT-VIEWS :=  $CXT || "/rest" || $config:app-root || "/views"
     let $REST-CXT-ACTNS :=  $CXT || "/rest" || $config:app-root || "/doc_actions"
     return      
            <div style="display:none;">
                <xf:model id="modelone">
                    <xf:instance>
                        <data xmlns="">
                            <lastupdate>2000-01-01</lastupdate>
                            <user>admin</user>
                        </data>
                    </xf:instance>

                    <xf:submission id="s-query-workflows"
                                    resource="{$REST-CXT-VIEWS}/about.html"
                                    method="get"
                                    replace="embedHTML"
                                    targetid="embedInline"
                                    ref="instance()"
                                    validate="false">
                        <xf:action ev:event="xforms-submit-done">
                            <xf:message level="ephemeral">Request for about page successful</xf:message>
                        </xf:action>                                    
                        <xf:action ev:event="xforms-submit-error">
                            <xf:message>Submission failed</xf:message>
                        </xf:action>
                    </xf:submission>


                    <xf:action ev:event="xforms-ready">
                        <xf:message level="ephemeral">Default: show about</xf:message>
                        <xf:action ev:event="xforms-value-changed">
                            <xf:dispatch name="DOMActivate" targetid="overviewTrigger"/>
                        </xf:action>
                    </xf:action>
                </xf:model>

                <xf:trigger id="overviewTrigger">
                    <xf:label>Overview</xf:label>
                    <xf:send submission="s-query-workflows"/>
                </xf:trigger>
                                  
                                               
            </div>
};