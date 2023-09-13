


		insert into receiverFieldSetup(pCountry,paymentMethodId,field,fieldRequired,minfieldLength,maxfieldLength,KeyWord
,createdBy,createdDate,modifiedBy,modifiedDate,isDropDown)
		select 12,2,field,fieldRequired,minfieldLength,maxfieldLength,KeyWord
,createdBy,createdDate,modifiedBy,modifiedDate,isDropDown FROM receiverFieldSetup(NOLOCK) where pCountry=0 and paymentMethodId=2

select * from countryMaster where countryName='australia'

select * FROM receiverFieldSetup(NOLOCK) where pCountry=12 and paymentMethodId=2
and field='Branch Name'
update receiverFieldSetup set fieldRequired='M' where pCountry=12 and paymentMethodId=2
and field='Branch Name'


