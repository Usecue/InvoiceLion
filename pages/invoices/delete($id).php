<?php

use MintyPHP\DB;
use MintyPHP\DBError;
use MintyPHP\Flash;
use MintyPHP\Router;

if (!empty($_POST)) {
    //check if this invoice is sent > if so... do not delete
    $invoice = DB::selectOne('SELECT `sent` FROM invoices WHERE tenant_id=? AND id=?', $_SESSION['user']['tenant_id'], $id);
    if(!$invoice['invoices']['sent']) {
        try {
            //remove references to invoicelines
            $hours = DB::update('UPDATE `hours` SET `hours`.invoiceline_id = NULL WHERE `tenant_id` = ? AND `invoiceline_id` IN (SELECT id FROM invoicelines WHERE invoice_id=?)', $_SESSION['user']['tenant_id'], $id);
            $subscriptionperiods = DB::update('UPDATE `subscriptionperiods` SET `subscriptionperiods`.invoiceline_id = NULL WHERE `tenant_id` = ? AND `invoiceline_id` IN (SELECT id FROM invoicelines WHERE invoice_id=?)', $_SESSION['user']['tenant_id'], $id);
            $deliveries = DB::update('UPDATE `deliveries` SET `deliveries`.invoiceline_id = NULL WHERE `tenant_id` = ? AND `invoiceline_id` IN (SELECT id FROM invoicelines WHERE invoice_id=?)', $_SESSION['user']['tenant_id'], $id);
            //remove invoicelines
            $rows2 = DB::delete('DELETE FROM `invoicelines` WHERE `tenant_id` = ? AND `invoice_id` = ?', $_SESSION['user']['tenant_id'], $id);
            //remove invoice
            $rows = DB::delete('DELETE FROM `invoices` WHERE `tenant_id` = ? AND `id` = ?', $_SESSION['user']['tenant_id'], $id);
            if ($rows && $rows2 && ($hours || $subscriptionperiods || $deliveries)) {
                Flash::set('success','Invoice deleted');
                Router::redirect('invoices/index');
            }
            $error = 'Invoice not deleted';
        } catch (DBError $e) {
            $error = 'Invoice not deleted: '.$e->getMessage();
        }
    } else {
        $error = 'Invoice not deleted';
    }
}