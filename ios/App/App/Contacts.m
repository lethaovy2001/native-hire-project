#import <Capacitor/Capacitor.h>

CAP_PLUGIN(Contacts, "Contacts",
           CAP_PLUGIN_METHOD(getAll, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(getFilteredContacts, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(requestAccess, CAPPluginReturnPromise);
           )
