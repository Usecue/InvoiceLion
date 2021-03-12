<?php
$subscriptiontypes = DB::selectPairs('select `id`,`name` from `subscriptiontypes` WHERE `tenant_id` = ?', $_SESSION['user']['tenant_id']);
$projects = DB::select('select `id`,`name`,`customer_id` from `projects` WHERE `tenant_id` = ? and `active` ORDER BY name', $_SESSION['user']['tenant_id']);
$customers = DB::selectPairs('select `id`,`name` from `customers`  WHERE `tenant_id` = ? ORDER BY `name`', $_SESSION['user']['tenant_id']);
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $data = $_POST;

    //set tax_percentage to NULL if the customer has tax_reverse_charge
	$tax_reverse_charge = DB::selectValue('select `tax_reverse_charge` from `customers` WHERE `tenant_id` = ? AND `id` = ?', $_SESSION['user']['tenant_id'], $data['subscriptions']['customer_id']);
    if ($tax_reverse_charge) $data['subscriptions']['tax_percentage']=NULL;

    if (!$data['subscriptions']['from']) $errors['subscriptions[from]'] = 'Date not set';
    if (!$data['subscriptions']['name']) $errors['subscriptions[name]'] = 'Name not set';
    if (!$data['subscriptions']['fee']) $errors['subscriptions[fee]'] = 'Fee not set';
    if (!$data['subscriptions']['months']) $errors['subscriptions[months]'] = 'Subscription period not set';
    if (!$data['subscriptions']['tax_percentage'] && !$tax_reverse_charge) $errors['subscriptions[tax_percentage]']='tax percentage not set';	
	if (!$data['subscriptions']['project_id']) $data['subscriptions']['project_id'] = null;
    if (!$data['subscriptions']['subscriptiontype_id']) $data['subscriptions']['subscriptiontype_id'] = null;
	if (!$data['subscriptions']['customer_id']) $errors['hours[customer_id]']='Customer not set';	
    if (!$data['subscriptions']['canceled']) $data['subscriptions']['canceled'] = null;
	if (!$data['subscriptions']['referral_customer_id']) $data['subscriptions']['referral_customer_id'] = null;
    
    if (!isset($errors)) {
        try {
            $rowsAffected = DB::update('UPDATE `subscriptions` SET `fee`=?, `tax_percentage`=?, `months`=?, `name`=?, `from`=?, `canceled`=?, `comment`=?, `subscriptiontype_id`=?, `customer_id`=?, `referral_customer_id`=?, `project_id`=? WHERE `tenant_id` = ? AND `id` = ?', $data['subscriptions']['fee'], $data['subscriptions']['tax_percentage'], $data['subscriptions']['months'], $data['subscriptions']['name'], $data['subscriptions']['from'], $data['subscriptions']['canceled'], $data['subscriptions']['comment'], $data['subscriptions']['subscriptiontype_id'], $data['subscriptions']['customer_id'], $data['subscriptions']['referral_customer_id'], $data['subscriptions']['project_id'], $_SESSION['user']['tenant_id'], $id);
            if ($rowsAffected !== false) {
                Flash::set('success', 'Subscription saved');
                Router::redirect('subscriptions/view/' . $id);
            }
            $error = 'Subscription not saved';
        } catch (DBError $e) {
            $error = 'Subscription not saved: ' . $e->getMessage();
        }
    }
} else {
    $data = DB::selectOne('SELECT * from `subscriptions` WHERE `tenant_id` = ? AND `id` = ?', $_SESSION['user']['tenant_id'], $id);
}
