// //
// Copyright 2005 SurveySite. All rights reserved.

// Name: Microsoft-www
// Date: 2006-11-16


// Multiple script protection.
if (!window.SiteRecruit_Globals) {

// Create the configuration, globals, and constants namespaces.
var SiteRecruit_Config = new Object();
var SiteRecruit_Globals = new Object();
var SiteRecruit_Constants = new Object();

// Validation variables.
SiteRecruit_Globals.parseFlag = false;
SiteRecruit_Globals.empty = false;

// Browser information.
SiteRecruit_Constants.browser = new Object();
SiteRecruit_Constants.browser.internetExplorer = 'Microsoft Internet Explorer';
SiteRecruit_Constants.browser.mozilla = 'Netscape';

// Check browser information.
SiteRecruit_Globals.browserName = navigator.appName; 
SiteRecruit_Globals.browserVersion = parseInt(navigator.appVersion);

// Initialize browser flags.
SiteRecruit_Globals.isInternetExplorer = false;
SiteRecruit_Globals.isMozilla = false;
SiteRecruit_Globals.isInternetExplorer7 = false;

// Check for Internet Explorer based browsers.
if (SiteRecruit_Globals.browserName == SiteRecruit_Constants.browser.internetExplorer)
{
    if (SiteRecruit_Globals.browserVersion > 3)
    {
        // Only 5.5 and above.
        var a = navigator.userAgent.toLowerCase();
        if (a.indexOf("msie 5.0") == -1 && a.indexOf("msie 5.0") == -1)
        {
            SiteRecruit_Globals.isInternetExplorer = true;
        }
        
        // Check for 7.
        if (a.indexOf("msie 7") != -1)
        {
            SiteRecruit_Globals.isInternetExplorer7 = true;
        }
    }
}

// Check for Mozilla based browsers.
if (SiteRecruit_Globals.browserName == SiteRecruit_Constants.browser.mozilla)
{
    if (SiteRecruit_Globals.browserVersion > 4)
    {
        SiteRecruit_Globals.isMozilla = true;
    }
}

// Cookie lifetime.
SiteRecruit_Constants.cookieLifetimeType = new Object();
SiteRecruit_Constants.cookieLifetimeType.duration = 1;
SiteRecruit_Constants.cookieLifetimeType.expireDate = 2;
    
// Invitation type.
SiteRecruit_Constants.invitationType = new Object();
SiteRecruit_Constants.invitationType.standard = 0;
SiteRecruit_Constants.invitationType.email = 1;
SiteRecruit_Constants.invitationType.domainDeparture = 2;
    
// Cookie type flags.
SiteRecruit_Constants.cookieType = new Object();
SiteRecruit_Constants.cookieType.alreadyAsked = 1;
SiteRecruit_Constants.cookieType.inProgress = 2;

// Alignment types.
SiteRecruit_Constants.horizontalAlignment = new Object();
SiteRecruit_Constants.horizontalAlignment.left = 0;
SiteRecruit_Constants.horizontalAlignment.middle = 1;
SiteRecruit_Constants.horizontalAlignment.right = 2;
SiteRecruit_Constants.verticalAlignment = new Object();
SiteRecruit_Constants.verticalAlignment.top = 0;
SiteRecruit_Constants.verticalAlignment.middle = 1;
SiteRecruit_Constants.verticalAlignment.bottom = 2;

// Survey cookie configuration.
SiteRecruit_Config.cookieName = 'msresearch';
SiteRecruit_Config.cookieDomain = '.microsoft.com';
SiteRecruit_Config.cookiePath = '/';

// Cookie element join character.
SiteRecruit_Constants.cookieJoinChar = ':';

// Settings for cookie lifetime.
SiteRecruit_Config.cookieLifetimeType = 1;

    // Duration of the cookie in days.
    SiteRecruit_Config.cookieDuration = 90;

// Duration of the rapid cookie.
SiteRecruit_Config.rapidCookieDuration = 0;
// //
// Copyright 2005 SurveySite. All rights reserved.

// KeepAlive class definition.
function SiteRecruit_KeepAlive()
{
    // Time between page checks.
    this.keepAlivePollDelay = 1000;

    // Unique (well, sorta) ID for this page.
    this.id = Math.random();

    // Attach methods.
    this.attemptStart = KeepAlive_attemptStart;
    this.checkCookie = KeepAlive_checkCookie;
    this.inProgressCookieExists = KeepAlive_inProgressCookieExists;

    // Start the KeepAlive if an in-progress cookie exists.
    function KeepAlive_attemptStart()
    {
        if (this.inProgressCookieExists())
        {
            setInterval('SiteRecruit_Globals.keepAlive.checkCookie()', this.keepAlivePollDelay);
        }
    }
    
    // Check and update the cookie.
    function KeepAlive_checkCookie()
    {
        if (this.inProgressCookieExists())
        {
            var j = SiteRecruit_Constants.cookieJoinChar;
            
            // Update the cookie with the current time and location.
            var c = SiteRecruit_Config.cookieName + '=' + SiteRecruit_Constants.cookieType.inProgress
                + j + escape(document.location)
                + j + (new Date()).getTime()
                + j + this.id
                + '; path=' + SiteRecruit_Config.cookiePath;
            
            if (SiteRecruit_Config.cookieDomain != '')
            {
                c += '; domain=' + SiteRecruit_Config.cookieDomain;
            }
            
            document.cookie = c;
        }
    }

    // Return true if an in-progress cookie exists.
    function KeepAlive_inProgressCookieExists()
    {
        var c = SiteRecruit_Config.cookieName + '=' + SiteRecruit_Constants.cookieType.inProgress;
    
        if (document.cookie.indexOf(c) != -1)
        {
            return true;
        }
        
        return false;
    }
}

// Create the KeepAlive if a suitable cookie exists.
SiteRecruit_Globals.keepAlive = new SiteRecruit_KeepAlive();
SiteRecruit_Globals.keepAlive.attemptStart();
// //
// Copyright 2005 SurveySite. All rights reserved.

// Broker class definition.
function SiteRecruit_PageConfigurationBroker()
{
    this.urls = new Array();
    this.pages = new Array();
    this.priorities = new Array();
        
    // Attach methods.
    this.start = PageConfigurationBroker_start;
    this.initializeMapping = PageConfigurationBroker_initializeMapping;
    this.getConfigurationForPage = PageConfigurationBroker_getConfigurationForPage;
    this.loadConfiguration = PageConfigurationBroker_loadConfiguration;

    // Start the Broker.
    function PageConfigurationBroker_start(url)
    {
        this.initializeMapping();
        
        // Decide if there are surveys to run for this page.
        var configuration = this.getConfigurationForPage(url);
        
        // If there is, load id up.
        if (configuration != null)
        {
            this.loadConfiguration(configuration);
        }
    }
    
    // Initializes the page mapping.
    function PageConfigurationBroker_initializeMapping()
    {
        var u = this.urls;
        var p = this.pages;
        var x = this.priorities;
        
                     
                            // http://www.microsoft.com/about
                u[0] = '//[\\w\\.-]+/about((/)|(/((default)|(index))\\.((html?)|(aspx?)|(mspx))))?$';
                p[0] = '/library/svy/SiteRecruit_PageConfiguration_2943mt1.js';
                x[0] = 0;
                                        
             
                            // http://www.microsoft.com/athome...
                u[1] = '//[\\w\\.-]+/athome';
                p[1] = '/library/svy/SiteRecruit_PageConfiguration_2943mt16.js';
                x[1] = 0;
                                        
             
                            // http://www.microsoft.com/athome/security...
                u[2] = '//[\\w\\.-]+/athome/security';
                p[2] = '/library/svy/SiteRecruit_PageConfiguration_2943mt12-2943mt16.js';
                x[2] = 1;
                                        
             
                            // http://www.microsoft.com/atwork...
                u[3] = '//[\\w\\.-]+/atwork';
                p[3] = '/library/svy/SiteRecruit_PageConfiguration_2943mt2.js';
                x[3] = 0;
                                        
             
                            // http://www.microsoft.com/australia/smallbusiness...
                u[4] = '//[\\w\\.-]+/australia/smallbusiness(/(?!sbrp)|$)';
                p[4] = '/library/svy/SiteRecruit_PageConfiguration_2933mt_Australia.js';
                x[4] = 0;
                                        
             
                            // http://www.microsoft.com/brasil/pequenasempresas...
                u[5] = '//[\\w\\.-]+/brasil/pequenasempresas';
                p[5] = '/library/svy/SiteRecruit_PageConfiguration_2933mt_Brazil.js';
                x[5] = 0;
                                        
             
                            // http://www.microsoft.com/business...
                u[6] = '//[\\w\\.-]+/business(/(?!executivecircle)|$)';
                p[6] = '/library/svy/SiteRecruit_PageConfiguration_2943mt8.js';
                x[6] = 0;
                                        
             
                            // http://www.microsoft.com/canada/smallbiz...
                u[7] = '//[\\w\\.-]+/canada/smallbiz(/(?!sbplus)|$)';
                p[7] = '/library/svy/SiteRecruit_PageConfiguration_2933mt_EnglishCanada.js';
                x[7] = 0;
                                        
             
                            // http://www.microsoft.com/china/smallbusiness...
                u[8] = '//[\\w\\.-]+/china/smallbusiness';
                p[8] = '/library/svy/SiteRecruit_PageConfiguration_2933mt_China.js';
                x[8] = 0;
                                        
             
                            // http://www.microsoft.com/communities...
                u[9] = '//[\\w\\.-]+/communities';
                p[9] = '/library/svy/SiteRecruit_PageConfiguration_2943mt4.js';
                x[9] = 0;
                                        
             
                            // http://www.microsoft.com/communities/forums/default.mspx
                u[10] = '//[\\w\\.-]+/communities/forums/default\\.mspx$';
                p[10] = '/library/svy/SiteRecruit_PageConfiguration_3320mt-forums-2943mt4.js';
                x[10] = 1;
                                        
             
                            // http://www.microsoft.com/downloads...
                u[11] = '//[\\w\\.-]+/downloads';
                p[11] = '/library/svy/SiteRecruit_PageConfiguration_2943mt30-2944mt1.js';
                x[11] = 0;
                                        
             
                            // http://www.microsoft.com/dynamics...
                u[12] = '//[\\w\\.-]+/dynamics';
                p[12] = '/library/svy/SiteRecruit_PageConfiguration_2943mt3.js';
                x[12] = 0;
                                        
             
                            // http://www.microsoft.com/education...
                u[13] = '//[\\w\\.-]+/education(/(?!facultyconnection)|$)';
                p[13] = '/library/svy/SiteRecruit_PageConfiguration_2943mt5.js';
                x[13] = 0;
                                        
             
                            // http://www.microsoft.com/events...
                u[14] = '//[\\w\\.-]+/events';
                p[14] = '/library/svy/SiteRecruit_PageConfiguration_2943mt6.js';
                x[14] = 0;
                                        
             
                            // http://www.microsoft.com/exchange...
                u[15] = '//[\\w\\.-]+/exchange';
                p[15] = '/library/svy/SiteRecruit_PageConfiguration_2943mt7.js';
                x[15] = 0;
                                        
             
                            // http://www.microsoft.com/france/entrepreneur...
                u[16] = '//[\\w\\.-]+/france/entrepreneur(/(?!plus)|$)';
                p[16] = '/library/svy/SiteRecruit_PageConfiguration_2933mt_France.js';
                x[16] = 0;
                                        
             
                            // http://www.microsoft.com/france/msdn...
                u[17] = '//[\\w\\.-]+/france/msdn';
                p[17] = '/library/svy/SiteRecruit_PageConfiguration_2944mt4-msdn.js';
                x[17] = 0;
                                        
             
                            // http://www.microsoft.com/france/technet...
                u[18] = '//[\\w\\.-]+/france/technet';
                p[18] = '/library/svy/SiteRecruit_PageConfiguration_2944mt4-technet.js';
                x[18] = 0;
                                        
             
                            // http://www.microsoft.com/france/windows...
                u[19] = '//[\\w\\.-]+/france/windows(/|$)';
                p[19] = '/library/svy/SiteRecruit_PageConfiguration_2944mt4-windows.js';
                x[19] = 0;
                                        
             
                            // http://www.microsoft.com/germany/kleinunternehmen...
                u[20] = '//[\\w\\.-]+/germany/kleinunternehmen(/(?!small-business-plus)|$)';
                p[20] = '/library/svy/SiteRecruit_PageConfiguration_2933mt_Germany.js';
                x[20] = 0;
                                        
             
                            // http://www.microsoft.com/germany/msdn/...
                u[21] = '//[\\w\\.-]+/germany/msdn';
                p[21] = '/library/svy/SiteRecruit_PageConfiguration_2944mt3-msdn.js';
                x[21] = 0;
                                        
             
                            // http://www.microsoft.com/germany/server...
                u[22] = '//[\\w\\.-]+/germany/server(/|$)';
                p[22] = '/library/svy/SiteRecruit_PageConfiguration_2944mt3-wss.js';
                x[22] = 0;
                                        
             
                            // http://www.microsoft.com/germany/windows/...
                u[23] = '//[\\w\\.-]+/germany/windows(/|$)';
                p[23] = '/library/svy/SiteRecruit_PageConfiguration_2944mt3-windows.js';
                x[23] = 0;
                                        
             
                            // http://www.microsoft.com/hardware
                u[24] = '//[\\w\\.-]+/hardware((/)|(/default\\.asp)|(/default\\.mspx)|(/default\\.aspx))?$';
                p[24] = '/library/svy/SiteRecruit_PageConfiguration_2546mt_Home.js';
                x[24] = 0;
                                        
             
                            // http://www.microsoft.com/hardware/broadbandnetworking
                u[25] = '//[\\w\\.-]+/hardware/broadbandnetworking((/)|(/default\\.asp)|(/default\\.mspx)|(/default\\.aspx))?$';
                p[25] = '/library/svy/SiteRecruit_PageConfiguration_2546mt_BroadbandNetworking.js';
                x[25] = 0;
                                        
             
                            // http://www.microsoft.com/hardware/digitalcommunication
                u[26] = '//[\\w\\.-]+/hardware/digitalcommunication((/)|(/((default)|(index))\\.((html?)|(aspx?)|(mspx))))?$';
                p[26] = '/library/svy/SiteRecruit_PageConfiguration_3370mt.js';
                x[26] = 0;
                                        
             
                            // http://www.microsoft.com/hardware/mouseandkeyboard/default.mspx
                u[27] = '//[\\w\\.-]+/hardware/mouseandkeyboard/default\\.mspx$';
                p[27] = '/library/svy/SiteRecruit_PageConfiguration_2546mt_MNKB.js';
                x[27] = 0;
                                        
             
                            // http://www.microsoft.com/industry/financialservices...
                u[28] = '//[\\w\\.-]+/industry/financialservices';
                p[28] = '/library/svy/SiteRecruit_PageConfiguration_2943mt50.js';
                x[28] = 0;
                                        
             
                            // http://www.microsoft.com/industry/government...
                u[29] = '//[\\w\\.-]+/industry/government';
                p[29] = '/library/svy/SiteRecruit_PageConfiguration_2943mt51.js';
                x[29] = 0;
                                        
             
                            // http://www.microsoft.com/industry/healthcare...
                u[30] = '//[\\w\\.-]+/industry/healthcare';
                p[30] = '/library/svy/SiteRecruit_PageConfiguration_2943mt54.js';
                x[30] = 0;
                                        
             
                            // http://www.microsoft.com/industry/hospitality...
                u[31] = '//[\\w\\.-]+/industry/hospitality';
                p[31] = '/library/svy/SiteRecruit_PageConfiguration_2943mt56.js';
                x[31] = 0;
                                        
             
                            // http://www.microsoft.com/industry/manufacturing...
                u[32] = '//[\\w\\.-]+/industry/manufacturing';
                p[32] = '/library/svy/SiteRecruit_PageConfiguration_2943mt52.js';
                x[32] = 0;
                                        
             
                            // http://www.microsoft.com/industry/professionalservices...
                u[33] = '//[\\w\\.-]+/industry/professionalservices';
                p[33] = '/library/svy/SiteRecruit_PageConfiguration_2943mt55.js';
                x[33] = 0;
                                        
             
                            // http://www.microsoft.com/industry/retail...
                u[34] = '//[\\w\\.-]+/industry/retail';
                p[34] = '/library/svy/SiteRecruit_PageConfiguration_2943mt53.js';
                x[34] = 0;
                                        
             
                            // http://www.microsoft.com/ISAserver...
                u[35] = '//[\\w\\.-]+/ISAserver';
                p[35] = '/library/svy/SiteRecruit_PageConfiguration_2943mt22.js';
                x[35] = 0;
                                        
             
                            // http://www.microsoft.com/italy/pmi...
                u[36] = '//[\\w\\.-]+/italy/pmi(/(?!plus)|$)';
                p[36] = '/library/svy/SiteRecruit_PageConfiguration_2933mt_Italy.js';
                x[36] = 0;
                                        
             
                            // http://www.microsoft.com/japan/msdn...
                u[37] = '//[\\w\\.-]+/japan/msdn';
                p[37] = '/library/svy/SiteRecruit_PageConfiguration_2944mt2-msdn.js';
                x[37] = 0;
                                        
             
                            // http://www.microsoft.com/japan/office...
                u[38] = '//[\\w\\.-]+/japan/office';
                p[38] = '/library/svy/SiteRecruit_PageConfiguration_2944mt2-office.js';
                x[38] = 0;
                                        
             
                            // http://www.microsoft.com/japan/smallbiz...
                u[39] = '//[\\w\\.-]+/japan/smallbiz';
                p[39] = '/library/svy/SiteRecruit_PageConfiguration_2933mt_Japan.js';
                x[39] = 0;
                                        
             
                            // http://www.microsoft.com/japan/technet...
                u[40] = '//[\\w\\.-]+/japan/technet';
                p[40] = '/library/svy/SiteRecruit_PageConfiguration_2944mt2-technet.js';
                x[40] = 0;
                                        
             
                            // http://www.microsoft.com/japan/windowsxp...
                u[41] = '//[\\w\\.-]+/japan/windowsxp';
                p[41] = '/library/svy/SiteRecruit_PageConfiguration_2944mt2-wxp.js';
                x[41] = 0;
                                        
             
                            // http://www.microsoft.com/learning
                u[42] = '//[\\w\\.-]+/learning((/)|(/default\\.asp)|(/default\\.mspx)|(/default\\.aspx))?$';
                p[42] = '/library/svy/SiteRecruit_PageConfiguration_2943mt9.js';
                x[42] = 0;
                                        
             
                            // http://www.microsoft.com/licensing...
                u[43] = '//[\\w\\.-]+/licensing';
                p[43] = '/library/svy/SiteRecruit_PageConfiguration_2943mt10.js';
                x[43] = 0;
                                        
             
                            // http://www.microsoft.com/mexico/pymes...
                u[44] = '//[\\w\\.-]+/mexico/pymes';
                p[44] = '/library/svy/SiteRecruit_PageConfiguration_2933mt_Mexico.js';
                x[44] = 0;
                                        
             
                            // http://www.microsoft.com/mexico/pymes/default.mspx
                u[45] = '//[\\w\\.-]+/mexico/pymes((/)|(/((default)|(index))\\.((html?)|(aspx?)|(mspx))))?$';
                p[45] = '/library/svy/SiteRecruit_PageConfiguration_2933mt_Mexico-Default.js';
                x[45] = 1;
                                        
             
                            // http://www.microsoft.com/midsizebusiness...
                u[46] = '//[\\w\\.-]+/midsizebusiness';
                p[46] = '/library/svy/SiteRecruit_PageConfiguration_3123mt.js';
                x[46] = 0;
                                        
             
                            // http://www.microsoft.com/netherlands/ondernemers...
                u[47] = '//[\\w\\.-]+/netherlands/ondernemers(/(?!plus)|$)';
                p[47] = '/library/svy/SiteRecruit_PageConfiguration_2933mt_Netherlands.js';
                x[47] = 0;
                                        
             
                            // http://www.microsoft.com/products/info/...
                u[48] = '//[\\w\\.-]+/products/info';
                p[48] = '/library/svy/SiteRecruit_PageConfiguration_2943mt31.js';
                x[48] = 0;
                                        
             
                            // http://www.microsoft.com/security...
                u[49] = '//[\\w\\.-]+/security';
                p[49] = '/library/svy/SiteRecruit_PageConfiguration_2943mt11-2944mt1.js';
                x[49] = 0;
                                        
             
                            // http://www.microsoft.com/smallbusiness...
                u[50] = '//[\\w\\.-]+/smallbusiness(/(?!small-business-plus)|$)';
                p[50] = '/library/svy/SiteRecruit_PageConfiguration_2933mt_UnitedStates.js';
                x[50] = 0;
                                        
             
                            // http://www.microsoft.com/spain/empresas...
                u[51] = '//[\\w\\.-]+/spain/empresas';
                p[51] = '/library/svy/SiteRecruit_PageConfiguration_2933mt_Spain.js';
                x[51] = 0;
                                        
             
                            // http://www.microsoft.com/sql...
                u[52] = '//[\\w\\.-]+/sql';
                p[52] = '/library/svy/SiteRecruit_PageConfiguration_2943mt14.js';
                x[52] = 0;
                                        
             
                            // http://www.microsoft.com/technet...
                u[53] = '//[\\w\\.-]+/technet(/(?!mnp_utility\\.mspx/framesmenu)|$)';
                p[53] = '/library/svy/SiteRecruit_PageConfiguration_2944mt1-2943mt33-3217mt.js';
                x[53] = 0;
                                        
             
                            // http://www.microsoft.com/technet/itsolutions/branch...
                u[54] = '//[\\w\\.-]+/technet/itsolutions/branch(/|$)';
                p[54] = '/library/svy/SiteRecruit_PageConfiguration_3248mt-B-2944mt1-2943mt33-3217mt.js';
                x[54] = 1;
                                        
             
                            // http://www.microsoft.com/technet/itsolutions/cits...
                u[55] = '//[\\w\\.-]+/technet/itsolutions/cits(/|$)';
                p[55] = '/library/svy/SiteRecruit_PageConfiguration_3248mt-C-2944mt1-2943mt33-3217mt.js';
                x[55] = 1;
                                        
             
                            // http://www.microsoft.com/technet/itsolutions/cits/interopmigration...
                u[56] = '//[\\w\\.-]+/technet/itsolutions/cits/interopmigration(/|$)';
                p[56] = '/library/svy/SiteRecruit_PageConfiguration_3248mt-I-2944mt1-2943mt33-3217mt.js';
                x[56] = 2;
                                        
             
                            // http://www.microsoft.com/technet/itsolutions/cits/mo...
                u[57] = '//[\\w\\.-]+/technet/itsolutions/cits/mo(/|$)';
                p[57] = '/library/svy/SiteRecruit_PageConfiguration_3248mt-M-2944mt1-2943mt33-3217mt.js';
                x[57] = 2;
                                        
             
                            // http://www.microsoft.com/technet/itsolutions/smbiz...
                u[58] = '//[\\w\\.-]+/technet/itsolutions/smbiz(/|$)';
                p[58] = '/library/svy/SiteRecruit_PageConfiguration_3248mt-S-2944mt1-2943mt33-3217mt.js';
                x[58] = 1;
                                        
             
                            // http://www.microsoft.com/technet/itsolutions/wssra...
                u[59] = '//[\\w\\.-]+/technet/itsolutions/wssra(/|$)';
                p[59] = '/library/svy/SiteRecruit_PageConfiguration_3248mt-W-2944mt1-2943mt33-3217mt.js';
                x[59] = 1;
                                        
             
                            // http://www.microsoft.com/technet/security...
                u[60] = '//[\\w\\.-]+/technet/security';
                p[60] = '/library/svy/SiteRecruit_PageConfiguration_2943mt34-2943mt33-2944mt1-3217mt.js';
                x[60] = 1;
                                        
             
                            // http://www.microsoft.com/technet/security/topics...
                u[61] = '//[\\w\\.-]+/technet/security/topics(/|$)';
                p[61] = '/library/svy/SiteRecruit_PageConfiguration_3248mt-topics-2944mt1-2943mt33-2943mt34.js';
                x[61] = 2;
                                        
             
                            // http://www.microsoft.com/windows/ie...
                u[62] = '//[\\w\\.-]+/windows/ie(/|$)';
                p[62] = '/library/svy/SiteRecruit_PageConfiguration_2943mt17.js';
                x[62] = 0;
                                        
             
                            // http://www.microsoft.com/windowsserver2003...
                u[63] = '//[\\w\\.-]+/windowsserver2003';
                p[63] = '/library/svy/SiteRecruit_PageConfiguration_2943mt15.js';
                x[63] = 0;
                                        
             
                            // http://www.microsoft.com/windowsvista....
                u[64] = '//[\\w\\.-]+/windowsvista(/|$)';
                p[64] = '/library/svy/SiteRecruit_PageConfiguration_2943mt21.js';
                x[64] = 0;
                                        
             
                            // http://www.microsoft.com/windowsxp...
                u[65] = '//[\\w\\.-]+/windowsxp';
                p[65] = '/library/svy/SiteRecruit_PageConfiguration_2943mt18.js';
                x[65] = 0;
                                        
             
                            // http://www.microsoft.com/windowsxp/mediacenter...
                u[66] = '//[\\w\\.-]+/windowsxp/mediacenter';
                p[66] = '/library/svy/SiteRecruit_PageConfiguration_2943mt19-2943mt18.js';
                x[66] = 1;
                                        
             
                            // http://www.microsoft.com/windowsxp/tabletpc
                u[67] = '//[\\w\\.-]+/windowsxp/tabletpc((/)|(/((default)|(index))\\.((html?)|(aspx?)|(mspx))))?$';
                p[67] = '/library/svy/SiteRecruit_PageConfiguration_2943mt20-2943mt18-default.js';
                x[67] = 2;
                                        
             
                            // http://www.microsoft.com/windowsxp/tabletpc...
                u[68] = '//[\\w\\.-]+/windowsxp/tabletpc';
                p[68] = '/library/svy/SiteRecruit_PageConfiguration_2943mt20-2943mt18.js';
                x[68] = 1;
                                        
            }
    
    // Return the appropriate configuration for the given URL, if any.
    function PageConfigurationBroker_getConfigurationForPage(url)
    {
        
        var currentScore = 0;
        var currentMatch = -1;
        
        // Iterate over each URL.
        for (var i = 0; i < this.urls.length; i++)
        {
            // Do the reg exp match.
            var r = new RegExp(this.urls[i], 'i');
            if (url.toString().search(r) != -1)
            {
                // Take the current if the score is equal or better.
                var newScore = this.priorities[i];
                if (newScore >= currentScore)
                {
                    currentMatch = i;
                    currentScore = newScore;
                }
            }
        }
        
        // If there was a match, return the appropriate page configuration.
        var page = null;
        if (currentMatch >= 0)
        {
            page = this.pages[currentMatch];
        }
        
                
        return page;
    }
    
    // Dynamically loads the associated configuration.
    function PageConfigurationBroker_loadConfiguration(configuration)
    {
        
        document.write('<script language="JavaScript" src="' + configuration + '"></script>');
    }
}

try
{
    // Only run if the browser is supported.
    if (SiteRecruit_Globals.isInternetExplorer || SiteRecruit_Globals.isMozilla)
    {
        // Create and start the Broker for the current location.
        SiteRecruit_Globals.broker = new SiteRecruit_PageConfigurationBroker();
        SiteRecruit_Globals.broker.start(window.location);
    }
}
catch (e)
{
    // Suppress any errors.
}

SiteRecruit_Globals.parseFlag = true;

// Multiple script protection.
}