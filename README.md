# XCode cloud API sample
The sample code in this repo is a sample of how to download the ipa for latest successful build from xcode.

Remember - this is a sample! There are some known limitations that are listed below:
- If you have multiple apps in appstore connect - this will download from the most recent app. Update `Fetching product build runs` to workaround or fix this.
- Will download from the most recent successful build across all workflows.

... and many more that arent listed! Its upto you to find them!

## Create API key
1. Login to AppStore Connect
2. Navigate to `Users and Access`
3. Select `Keys` tab.
4. Ensure `App Store Connect API` is selected for __Key Type__
5. Take note of the `Issuer ID` on this page.
6. Press the `+` icon to create a new API key. Give it any name, ensure it has `Developer` access.
7. Take note of the newly created `Key Id`
8. Press the download button to get the `.p8` private key file

## Setup Github

Create the following secrets.
- ASC_AUTH_KEY - this is the contents of the *.p8 file that Apple provides.
- ASC_ISSUER_ID - the issuer id unique to your Apple account
- ASC_KEY_ID - The key id corresponding to the AuthKey_*.p8 that you have downloaded from Apple that

At this point you should be able to run in github actions.

## Running locally

When running locally....

```
brew install chruby ruby-install
```

Then configure your `.zshrc` (or bash) as per the output of brew. Add `chruby.sh` and `auto.sh` in your startup file.

At this point you can install ruby.
```
ruby-install ruby `cat .ruby-version`
```

then finally launch a new terminal and install the dependencies
```
bundle install
```

at this point you can just run `./download.sh` to download the latest ipa.