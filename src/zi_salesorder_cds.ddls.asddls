@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Core Data Services (CDS) View Entity - Sales Orders'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #TRANSACTIONAL
}
define view entity ZI_SalesOrder_CDS
  as select from vbak as Header
  association [0..*] to vbap as _Items
    on $projection.SalesOrder = _Items.vbeln
{
  key Header.vbeln as SalesOrder,
      Header.erdat as CreationDate,
      Header.erzet as CreationTime,
      Header.ernam as CreatedByUser,
      Header.auart as OrderType,
      Header.kunnr as SoldToParty,
      @Semantics.amount.currencyCode: 'Currency'
      Header.netwr as NetAmount,
      Header.waerk as Currency,
      
      /* Associations */
      _Items
}

