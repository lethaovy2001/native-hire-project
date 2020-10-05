package io.ionic.starter;

import android.Manifest;
import android.content.pm.PackageManager;
import android.provider.ContactsContract;
import android.content.ContentResolver;
import android.database.Cursor;

import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.NativePlugin;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;

import java.util.ArrayList;

@NativePlugin(
        requestCodes = {Contacts.GET_ALL_REQUEST}
)
public class Contacts extends Plugin {
    static final int GET_ALL_REQUEST = 30033;

    @PluginMethod()
    public void getAll(PluginCall call) {
        getContacts(call, "");
    }

    @PluginMethod()
    public void getFilteredContacts(PluginCall call) {
        String filter = "DISPLAY_NAME = '" + call.getString("firstName") + "'";
        getContacts(call, filter);
    }

    @PluginMethod()
    public void isAuthorized(PluginCall call) {
        if (!hasPermission(Manifest.permission.READ_CONTACTS) ||
                !hasPermission(Manifest.permission.WRITE_CONTACTS)) {
            saveCall(call);
            pluginRequestPermissions(new String[] {
                    Manifest.permission.READ_CONTACTS,
                    Manifest.permission.WRITE_CONTACTS}, GET_ALL_REQUEST);
        }
        call.success();
    }

    protected void getContacts(PluginCall call, String filter) {
        ContentResolver contentResolver = this.getContext().getContentResolver();
        JSArray contacts = new JSArray();
        Cursor cursor = contentResolver.query(
                ContactsContract.Contacts.CONTENT_URI,
                null,
                filter,
                null,
                null);

        if (cursor.getCount() > 0) {
            while (cursor != null && cursor.moveToNext()) {
                JSObject contact = new JSObject();
                String id = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts._ID));
                String name = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME));
                ArrayList<String> phoneNumbers = retrievePhoneNumbers(contentResolver, id);
                ArrayList<String> emailAddresses = retrieveEmailAddress(contentResolver, id);

                contact.put("firstName", name);
                contact.put("lastName", "");
                contact.put("phoneNumbers", new JSArray(phoneNumbers));
                contact.put("emailAddresses", new JSArray(emailAddresses));
                contacts.put(contact);
            }
        }
        cursor.close();

        JSObject result = new JSObject();
        result.put("contacts", contacts);
        call.success(result);
    }

    protected ArrayList<String> retrieveEmailAddress(ContentResolver contentResolver, String id) {
        ArrayList<String> emailAddresses = new ArrayList<>();
        String emailKind = ContactsContract.CommonDataKinds.Email.DATA;
        Cursor emailCursor = contentResolver.query(
                ContactsContract.CommonDataKinds.Email.CONTENT_URI,
                null,
                ContactsContract.CommonDataKinds.Email.CONTACT_ID + " = ?",
                new String[] {id},
                null);
        while (emailCursor.moveToNext()) {
            String email = emailCursor.getString(emailCursor.getColumnIndex(emailKind));
            emailAddresses.add(email);
        }
        emailCursor.close();
        return emailAddresses;
    }

    protected ArrayList<String> retrievePhoneNumbers(ContentResolver contentResolver, String id) {
        ArrayList<String> phoneNumbers = new ArrayList<>();
        String phoneKind = ContactsContract.CommonDataKinds.Phone.NUMBER;
        Cursor phoneCursor = contentResolver.query(
                ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                null,
                ContactsContract.CommonDataKinds.Phone.CONTACT_ID + " = ?",
                new String[]{id},
                null);
        while (phoneCursor.moveToNext()) {
            String phoneNo = phoneCursor.getString(phoneCursor.getColumnIndex(phoneKind));
            phoneNumbers.add(phoneNo);
        }
        phoneCursor.close();
        return phoneNumbers;
    }

    @Override
    protected void handleRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.handleRequestPermissionsResult(requestCode, permissions, grantResults);

        PluginCall savedCall = getSavedCall();
        if (savedCall == null) {
            return;
        }

        for (int result : grantResults) {
            if (result == PackageManager.PERMISSION_DENIED) {
                savedCall.error("User denied permission");
                return;
            }
        }
        if (requestCode == GET_ALL_REQUEST) {
            savedCall.success();
            this.getAll(savedCall);
        }
    }
}
