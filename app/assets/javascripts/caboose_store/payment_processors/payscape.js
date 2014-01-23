
PaymentProcessor = function();

/*
 * Authorizes payment for an order.
 * 
 * Options:
 *   order_id       : The id of the order. 
 *   address        : The billing address.
 *   zip            : The billing zip code.
 *   card_num       : The 15-16 digit card number.
 *   exp_date       : Expiration date in mmYY format. 
 *   security_code  : The security code on the back of the card.
 *   
 * Called on /checkout/billing when order information has been confirmed and ready for authorization.
 * Should set any fields values in the hidden form and submit the form.
 */   
PaymentProcessor.authorize = function(options)
{
  // TODO: Implement this  
};
