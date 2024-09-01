import { join } from 'path';

export default {
    primary: {
        email: 'test1@void.com',
        password: 'SuperSecret!',
        sub: 10_101_010,
        email_verified: true,
        username: 'johndoe',
        display_name: 'John Doe',
        profile: '',
        picture: 'https://avatars.githubusercontent.com/u/44910820?v=4',
        storageState: join(__dirname, 'storageStates/primary.json'),
    },
    secondary: {
        email: 'test2@void.com',
        password: 'SuperSecret!',
        sub: 20_202_020,
        email_verified: false,
        username: 'janedoe',
        display_name: 'Jane Doe',
        profile: '',
        picture: 'https://avatars.githubusercontent.com/u/44910820?v=4',
        storageState: join(__dirname, 'storageStates/secondary.json'),
    },
};
