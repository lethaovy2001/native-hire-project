import { Plugins } from '@capacitor/core';

const { Contacts } = Plugins;

export interface Contact {
  id: string;
  firstName: string;
  lastName: string;
  phoneNumbers: string[];
  emailAddresses: string[];
}

export const getContacts = async (): Promise<Contact[]> => {
  try {
    const auth = await Contacts.isAuthorized();
    const result = await Contacts.getAll();
    return result.contacts;
  } catch (e) {
    console.error(`ERR (${getContacts.name}):`, e);
  }

  return [];
};
