# Oplink

- Manages ciao's oplink customers
- Uses a rails framework and communicates with oplink database servers as to perform activationn and deactivation requests!
- We also build an api to provide a tunnel for csn integration.

### How the API works for csn:
> Add Customer Method
* post request using the url of the following format
* http://oplink.ciaocrm.com/csnCustomers/addCustomer?token=TOKEN&phone=PHONE&first=FIRST&last=LAST&country=AFRICA&email=EMAIL
* token is the authorization header we will provide you
* first, last, phone and email are valid customer information
* The possible API responses are: Customer was successfully created,
  - Error related with wrong/missing customer information or duplicate email,
  - Error due to invalid TOKEN, Error due to wrong format of the request!
* For a successful creation we provide a user id. Please use it to make a payment in the future.

> Add Opu Method
* post request using the url of the following format
* http://oplink.ciaocrm.com/csnCustomers/addOpu?token=TOKEN&first=FIRST&last=LAST&sn=SERIALNO
* token is the authorization header we will provide you
* first, last are valid customer information
* serial number can be found on the back of the OPU box
* The possible API responses are: Opu for customer was successfully created,
  - Error related with wrong/missing opu information or duplicate serial number,
  - Error due to invalid TOKEN, Error due to wrong format of the request!

> Add Payment Method
* post request using the url of the following format
* http://oplink.ciaocrm.com/csnCustomers/addPayment?user_id=ID&token=TOKEN&amount=0.0&sn=SN
* user_id is what you received when the customer was created
* token is the authorization header
* amount is how much you are adding a opu
* sn is that opu's number
* The possible API responses are: Payment successful for customer, Couldn't find customer or OPU
  - Error related with wrong opu or customer information or missing amount,
  - Error due to invalid TOKEN, Error due to wrong format of the request!

### High level overview
When a customer comes up to us and wants to buy the product and start with 1 opu.
There are 3 steps we need to take:
- Create that customer in our database.
- Add an OPU
- Add payment to that opu. This will automatically activate the opu and the customer which this opu belongs to.
- Set expiration date a month from the activation date. Lastly it will send an email notification to the admin users.
- TODO (adding fields for each of the devices)
  - Of course there will be a need to add/modify/delete/opus and other devices
  - For now we treat the devices as part of the package belonging to a customer.


## Some tools I used
- Rufus scheduler to deactivate the opu device upon expiration date and send notificatons
- Json API to communicate with csn to add customers
- Savon Client to communicate with oplink API to send activation/deactivation requests and get info about a particular device
- Twitter bootsrap for the UI
- Devise for authentication with signup limited to admins

### A word about the css, nivo slider
Be sure to add this line in application.rb and set assets.compile to true in production.rb
```sh
$ config.assets.precompile += ['locales/*.css.scss']
```
If you run into trouble run
```sh
$ rake tmp:cache:clear AND rake assets:clean
```

