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
    let authorization = await Contacts.requestAccess();
    console.log(authorization)
    const result = await Contacts.getAll();
    //const result = await Contacts.getFilteredContacts({firstName: "Ap"})
    return result.contacts;
  } catch (e) {
    console.error(`ERR (${getContacts.name}):`, e);
  }

  return [];
};
