oplink
======
Manage ciao's oplink customers


This app uses a rails framework and communicates and servers as a management portal for ciao oplink security products.
It also serves as a tunnel for csn integration.

How the API works for csn:
==========================

add payment request sample 
********************************************************************************************************************************************
* post request using the url of the following format																					   *
*																																		   *
* http://oplink.ciaocrm.com/csnCustomers/addPayment?user_id=1&token=uewyiyutywegfysdvcj&amount=1.2&sn=13110000C83A351FB380                 *
* where token is the authorization header 																								   *
* amount, serial number of opu(sn), are required fields 																				   *
********************************************************************************************************************************************

add customer request sample
********************************************************************************************************************************************
* post request using the url of the following format																					   *
*																																		   *
* http://oplink.ciaocrm.com/csnCustomers/addCustomer?token=uewyiyutywegfysdvcj&phone=76756756&first=x&last=y&country=africa&email=t@t.com  *
*																																		   *
* where token is the authorization header 																								   *
* phone, first, last, country, email are required fields 																				   *
********************************************************************************************************************************************

High level overview
=====================
When a customer comes up to us and wants to buy the product and start with 1 opu.
There are 3 steps we need to take:
1. Create that customer in our database.
2. Add an OPU
3. Add payment to that opu. This will automatically activate the opu, customer, set actvation and expiration date. At the same time it will send an email notification to the admin users.
*Of course there will be a need to add/modify/delete/opus and other devices
*For now we treat the devices as part of the package belonging to a customer.


Some tools I used
==================
Rufus scheduler to deactivate the opu device upon expiration date and send notificatons
Created Json API to communicate with csn to add customers
Used Savon Client to communicate with oplink API to send activation/deactivation requests and get info about a particular device
Twitter bootsrap for the views with some customizations
Devise for authentication with signup limited to only admins