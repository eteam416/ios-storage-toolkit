import Foundation

/// Bundled ad-blocking and tracker-blocking rule lists in WebKit Content Blocker JSON format.
/// These are compiled by WKContentRuleListStore and applied to WKWebView.
///
/// Rule format documentation: https://developer.apple.com/documentation/safariservices/creating-a-content-blocker
///
/// Version: 1.0.0
/// Strategy: Layered blocking — ad domains, tracker domains, and annoyances are separate lists
/// for granular control and independent update capability.
enum AdBlockRules {

    // MARK: - Ad Domain Rules

    /// Blocks requests to known advertising domains.
    static let adDomainRules = """
    [
        {
            "trigger": {
                "url-filter": ".*",
                "if-domain": [
                    "*doubleclick.net",
                    "*googlesyndication.com",
                    "*googleadservices.com",
                    "*google-analytics.com",
                    "*adnxs.com",
                    "*adsrvr.org",
                    "*adform.net",
                    "*serving-sys.com",
                    "*moatads.com",
                    "*pubmatic.com",
                    "*openx.net",
                    "*rubiconproject.com",
                    "*casalemedia.com",
                    "*advertising.com",
                    "*adcolony.com",
                    "*admob.com",
                    "*mopub.com",
                    "*unity3d.com/ads",
                    "*inmobi.com",
                    "*taboola.com",
                    "*outbrain.com",
                    "*revcontent.com",
                    "*mgid.com"
                ]
            },
            "action": {
                "type": "block"
            }
        },
        {
            "trigger": {
                "url-filter": ".*",
                "resource-type": ["script", "image", "raw"],
                "if-domain": [
                    "*adsrvr.org",
                    "*adnxs.com",
                    "*criteo.com",
                    "*criteo.net",
                    "*amazon-adsystem.com",
                    "*media.net"
                ]
            },
            "action": {
                "type": "block"
            }
        },
        {
            "trigger": {
                "url-filter": ".*\\\\.ad[s]?\\\\..*"
            },
            "action": {
                "type": "block"
            }
        },
        {
            "trigger": {
                "url-filter": ".*pagead.*"
            },
            "action": {
                "type": "block"
            }
        },
        {
            "trigger": {
                "url-filter": ".*\\\\/ad[sx]?\\\\/.*"
            },
            "action": {
                "type": "block"
            }
        }
    ]
    """

    // MARK: - Tracker Domain Rules

    /// Blocks known tracking and fingerprinting domains.
    static let trackerDomainRules = """
    [
        {
            "trigger": {
                "url-filter": ".*",
                "if-domain": [
                    "*facebook.net/tr",
                    "*connect.facebook.net",
                    "*pixel.facebook.com",
                    "*analytics.twitter.com",
                    "*t.co/i",
                    "*scorecardresearch.com",
                    "*quantserve.com",
                    "*mixpanel.com",
                    "*segment.io",
                    "*segment.com",
                    "*hotjar.com",
                    "*fullstory.com",
                    "*mouseflow.com",
                    "*crazyegg.com",
                    "*optimizely.com",
                    "*newrelic.com",
                    "*nr-data.net",
                    "*amplitude.com"
                ]
            },
            "action": {
                "type": "block"
            }
        },
        {
            "trigger": {
                "url-filter": ".*\\\\/collect\\\\?.*",
                "resource-type": ["raw"]
            },
            "action": {
                "type": "block"
            }
        },
        {
            "trigger": {
                "url-filter": ".*beacon.*",
                "resource-type": ["raw", "image"]
            },
            "action": {
                "type": "block"
            }
        },
        {
            "trigger": {
                "url-filter": ".*tracking.*pixel.*",
                "resource-type": ["image"]
            },
            "action": {
                "type": "block"
            }
        }
    ]
    """

    // MARK: - Annoyance Rules (Policy-Safe)

    /// Blocks common annoyances: cookie banners, newsletter popups, social widgets.
    /// Only blocks elements that are clearly non-essential overlays.
    static let annoyanceRules = """
    [
        {
            "trigger": {
                "url-filter": ".*",
                "if-domain": [
                    "*cookiebot.com",
                    "*cookielaw.org",
                    "*cookieconsent.com",
                    "*osano.com",
                    "*trustarc.com",
                    "*onetrust.com"
                ]
            },
            "action": {
                "type": "block"
            }
        },
        {
            "trigger": {
                "url-filter": ".*newsletter.*popup.*",
                "resource-type": ["script"]
            },
            "action": {
                "type": "block"
            }
        },
        {
            "trigger": {
                "url-filter": ".*push.*notification.*prompt.*",
                "resource-type": ["script"]
            },
            "action": {
                "type": "block"
            }
        }
    ]
    """
}
