<?php

use MintyPHP\DB;
use MintyPHP\DBError;
use MintyPHP\Flash;
use MintyPHP\InvoiceTemplate;
use MintyPHP\Router;

$customer = DB::selectOne('select * from `customers` WHERE `tenant_id` = ? AND `id` = ?', $_SESSION['user']['tenant_id'], $customerId);
if (!$customerId) {
    Router::redirect('invoices/select');
}
$highest_invoice_number = DB::selectValue('SELECT MAX(number) FROM invoices WHERE `tenant_id` = ?', $_SESSION['user']['tenant_id']);
$hours = DB::select('SELECT * FROM `hours` WHERE invoiceline_id IS NULL AND hourly_fee IS NOT NULL AND `customer_id` = ? AND `tenant_id` = ? ORDER BY `date`', $customerId, $_SESSION['user']['tenant_id']);
$deliveries = DB::select('SELECT * FROM `deliveries` WHERE invoiceline_id IS NULL AND `customer_id` = ? AND `tenant_id` = ?', $customerId, $_SESSION['user']['tenant_id']);
$subscriptionperiods = DB::select('SELECT * FROM subscriptions, subscriptionperiods WHERE subscriptionperiods.subscription_id = subscriptions.id AND subscriptionperiods.invoiceline_id IS NULL AND subscriptions.customer_id = ? AND subscriptions.tenant_id = ?', $customerId, $_SESSION['user']['tenant_id']);
$template = DB::selectValue('SELECT `invoiceline_template` from `templates` WHERE `tenant_id` = ? AND `language_id`=?', $_SESSION['user']['tenant_id'], $customer['customers']['language_id']);

$invoicelines = array();
foreach ($hours as $row) {
    $subtotal = $row['hours']['hours_worked'] * $row['hours']['hourly_fee'];
    $tax_percentage = $row['hours']['tax_percentage'];
    if ($tax_percentage) {
        $total = $subtotal * ((100 + $tax_percentage) / 100);
    } else {
        $total = $subtotal;
    }

    $name = InvoiceTemplate::render($template, array('type' => 'hours', 'hours' => $row['hours']));
    $invoicelines['hours_' . $row['hours']['id']] = array(
        'type' => 'hours',
        'name' => trim(str_replace("\n", " ", $name)),
        'subtotal' => $subtotal,
        'tax' => ($total - $subtotal),
        'tax_percentage' => $tax_percentage,
        'total' => $total,
    );
}
foreach ($deliveries as $row) {
    $subtotal = $row['deliveries']['subtotal'];
    $tax_percentage = $row['deliveries']['tax_percentage'];
    if ($tax_percentage) {
        $total = $subtotal * ((100 + $tax_percentage) / 100);
    } else {
        $total = $subtotal;
    }

    $name = InvoiceTemplate::render($template, array('type' => 'delivery', 'delivery' => $row['deliveries']));
    $invoicelines['deliveries_' . $row['deliveries']['id']] = array(
        'type' => 'delivery',
        'name' => trim(str_replace("\n", " ", $name)),
        'subtotal' => $subtotal,
        'tax' => ($total - $subtotal),
        'tax_percentage' => $tax_percentage,
        'total' => $total,
    );
}
foreach ($subscriptionperiods as $row) {
    $subtotal = $row['subscriptions']['fee'];
    $tax_percentage = $row['subscriptions']['tax_percentage'];
    if ($tax_percentage) {
        $total = $subtotal * ((100 + $tax_percentage) / 100);
    } else {
        $total = $subtotal;
    }

    $name = InvoiceTemplate::render($template, array('type' => 'subscription', 'subscription' => $row['subscriptions'], 'subscriptionperiod' => $row['subscriptionperiods']));
    $invoicelines['subscriptionperiods_' . $row['subscriptionperiods']['id']] = array(
        'type' => 'subscription',
        'name' => trim(str_replace("\n", " ", $name)),
        'subtotal' => $subtotal,
        'tax' => ($total - $subtotal),
        'tax_percentage' => $tax_percentage,
        'total' => $total,
    );
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $data = $_POST;
    // set error when no invoicelines are selected
    if (!isset($errors)) {
        $error = 'Invoice not added';
        try {
            $invoicelines = array_filter($invoicelines, function ($key) use ($data) {return in_array($key, $data['invoicelines']);}, ARRAY_FILTER_USE_KEY);

            $sums = array('subtotal' => 0, 'tax' => 0, 'total' => 0);
            foreach ($invoicelines as $invoiceline) {
                $sums['subtotal'] += $invoiceline['subtotal'];
                $sums['tax'] += $invoiceline['tax'];
                $sums['total'] += $invoiceline['total'];
            }

            //begin();
            $invoice_id = DB::insert('INSERT INTO `invoices` (`tenant_id`, `number`, `name`, `date`, `customer_id`, `subtotal`, `tax`, `total`) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', $_SESSION['user']['tenant_id'], ($highest_invoice_number + 1), $data['invoices']['name'], date('Y-m-d'), $customerId, $sums['subtotal'], $sums['tax'], $sums['total']);
            foreach ($invoicelines as $key => $invoiceline) {
                $invoiceline_id = DB::insert('INSERT INTO `invoicelines` (`tenant_id`, `invoice_id`, `type`, `name`, `subtotal`, `tax`, `tax_percentage`, `total`) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', $_SESSION['user']['tenant_id'], $invoice_id, $invoiceline['type'], $invoiceline['name'], $invoiceline['subtotal'], $invoiceline['tax'], $invoiceline['tax_percentage'], $invoiceline['total']);
                list($table, $id) = explode('_', $key);
                switch ($table) {
                    case 'hours':
                        DB::update('UPDATE `hours` SET `invoiceline_id` = ? WHERE `tenant_id` = ? AND `id` = ?', $invoiceline_id, $_SESSION['user']['tenant_id'], $id);
                        break;
                    case 'deliveries':
                        DB::update('UPDATE `deliveries` SET `invoiceline_id` = ? WHERE `tenant_id` = ? AND `id` = ?', $invoiceline_id, $_SESSION['user']['tenant_id'], $id);
                        break;
                    case 'subscriptionperiods':
                        DB::update('UPDATE `subscriptionperiods` SET `invoiceline_id` = ? WHERE `tenant_id` = ? AND `id` = ?', $invoiceline_id, $_SESSION['user']['tenant_id'], $id);
                        break;
                }
            }
            //commit();

            if ($invoice_id) {
                Flash::set('success', 'Invoice added');
                Router::redirect('invoices/index');
            }
            $error = 'Invoice not added';
        } catch (DBError $e) {
            //rollback();
            $error = 'Invoice not added: ' . $e->getMessage();
        }
    }
} else {
    $data = array('invoices' => array('number' => ($highest_invoice_number + 1), 'name' => null, 'date' => Date('Y-m-d'), 'sent' => null, 'paid' => null, 'reminder1' => null, 'reminder2' => null, 'customer_id' => null));
}
