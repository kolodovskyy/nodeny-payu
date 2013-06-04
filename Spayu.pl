#!/usr/bin/perl
# by Yuriy Kolodovskyy aka Lexx
# kolodovskyy@ukrindex.com
# +380445924814
# last 20130419

use Digest::HMAC_MD5 qw(hmac_md5 hmac_md5_hex);
use Text::Iconv;
use Encode;

sub PY_main
{
  $MERCHANT = "MERCHANT";
  $SECRET_KEY = "SECRET_KEY";
  $STAT_HOST = "STAT_HOST";

  if ($F{result} eq '1') {
    &OkMess('Платеж не был проведен.');
    return;
  }

  if ($F{ok}) {
    &OkMess('Платеж проведен успешно.');
    return;
  }


  $paket=&sql_select_line($dbh, "SELECT price, name FROM plans2 WHERE id=" . $pm->{paket});

  $paket->{name} =~ s/^\[\d+\]//g;
  &Message("<h2>Оплата через PayU</h2><br><b>ФИО:</b> $pm->{fio}<br><b>Номер договора:</b> $pm->{name}<br><b>Текущий тарифный план: </b>$paket->{name}<br><b>Стоимость: </b>$paket->{price}&nbsp$gr");
  
  if ($F{process} && $F{amount} >= 10) {
    $iconv = Text::Iconv->new("windows-1251", "utf-8");

    my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=CORE::localtime(time);
    $ORDER_DATE = sprintf "%4d-%02d-%02d %02d:%02d:%02d",$year+1900,$mday,$mon+1,$hour,$min,$sec;

    $pm->{fio} =~ /^(\S*)\s+(\S*)/;
    $BILL_LNAME = $1;
    $BILL_FNAME = $2;
    
    $ORDER_REF = "$Mid";
    $ORDER_PNAME = "Услуги Интернет";
    $ORDER_PINFO = "Доступ к сети Интернет";
    $ORDER_PCODE = "1";
    $ORDER_PRICE = "$F{amount}";
    $ORDER_QTY = "1";
    $ORDER_VAT = "0";
    $ORDER_SHIPPING = "0";
    $PRICES_CURRENCY = "UAH";
    $LANGUAGE = "RU";

    $ORDER_HASH =  hmac_md5_hex(
      length($MERCHANT) . $MERCHANT .
      length($ORDER_REF) . $ORDER_REF .
      length($ORDER_DATE) . $ORDER_DATE .
      length(Encode::encode_utf8($ORDER_PNAME)) . $iconv->convert($ORDER_PNAME) .
      length($ORDER_PCODE) . $ORDER_PCODE .
      length(Encode::encode_utf8($ORDER_PINFO)) . $iconv->convert($ORDER_PINFO) .
      length($ORDER_PRICE) . $ORDER_PRICE .
      length($ORDER_QTY) . $ORDER_QTY .
      length($ORDER_VAT) . $ORDER_VAT .
      length($ORDER_SHIPPING) . $ORDER_SHIPPING .
      length($PRICES_CURRENCY) . $PRICES_CURRENCY, $SECRET_KEY);

    &Message("
      <div class=nav nowrap>
       <b>Пополнение баланса на сумму: </b>$F{amount}&nbsp$gr<br><br>
       <form accept-charset=\"UTF-8\" name=\"payform\" method=\"POST\" action=\"https://secure.payu.ua/order/lu.php\">
          <input type=\"hidden\" name=\"MERCHANT\" value=\"$MERCHANT\">
          <input type=\"hidden\" name=\"ORDER_REF\" value=\"$ORDER_REF\">
          <input type=\"hidden\" name=\"ORDER_DATE\" value=\"$ORDER_DATE\">
          <input type=\"hidden\" name=\"ORDER_PNAME[]\" value=\"$ORDER_PNAME\">
          <input type=\"hidden\" name=\"ORDER_PINFO[]\" value=\"$ORDER_PINFO\">
          <input type=\"hidden\" name=\"ORDER_PCODE[]\" value=\"$ORDER_PCODE\">
          <input type=\"hidden\" name=\"ORDER_PRICE[]\" value=\"$ORDER_PRICE\">
          <input type=\"hidden\" name=\"ORDER_VAT[]\" value=\"$ORDER_VAT\">
          <input type=\"hidden\" name=\"ORDER_QTY[]\" value=\"$ORDER_QTY\">
          <input type=\"hidden\" name=\"ORDER_SHIPPING\" value=\"$ORDER_SHIPPING\">
          <input type=\"hidden\" name=\"PRICES_CURRENCY\" value=\"$PRICES_CURRENCY\">
          <input type=\"hidden\" name=\"LANGUAGE\" value=\"$LANGUAGE\">
          <input type=\"hidden\" name=\"ORDER_HASH\" value=\"$ORDER_HASH\">
          <input type=\"hidden\" name=\"BACK_REF\" value=\"http://$STAT_HOST$script?uu=$F{uu}&pp=$F{pp}&a=$F{a}&ok=yes\">
          <input type=\"hidden\" name=\"BILL_FNAME\" value=\"$BILL_FNAME\">
          <input type=\"hidden\" name=\"BILL_LNAME\" value=\"$BILL_LNAME\">
        
          <input type=submit value='Перейти к оплате'>
        </form></div>");
    #<input type=\"hidden\" name=\"TESTORDER\" value=\"TRUE\">
    #<input type=\"hidden\" name=\"DEBUG\" value=\"1\">
  } else {
    &Message(
      &form('!'=>1,'process'=>'yes',
        "<span class=data2><font color=red>Минимальная сумма платежа 10 грн</font></span><br><br>".
        "<b>Сумма к оплате: </b>".&input_t("amount",$paket->{price},10,10)." $gr".$br2.
        &submit_a('Оплатить'))
    );
  }
}
1;
