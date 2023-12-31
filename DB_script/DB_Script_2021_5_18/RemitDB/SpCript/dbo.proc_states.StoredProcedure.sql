USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_states]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	EXEC proc_states @countryId = '2', @user = 'admin'
*/
CREATE proc [dbo].[proc_states] (
	 @flag			VARCHAR(20)	= NULL
	,@stateId		INT			= NULL
	,@countryId		INT			= NULL
	,@user			VARCHAR(30)	= NULL
)
AS
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRY
	IF EXISTS(SELECT 'X' FROM countryStateMaster WHERE countryId = @countryId)
	BEGIN
		EXEC proc_errorHandler 1, 'State already Generated', @countryId		
		RETURN
	END
	SELECT @flag = countryName FROM countryMaster WHERE countryId = @countryId
	
	IF(@flag='United States')	
	BEGIN
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'AL', 'Alabama', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'AK', 'Alaska', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'AZ', 'Arizona', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'AR', 'Arkansas', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'CA', 'California', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'CO', 'Colorado', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'CT', 'Connecticut', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'DE', 'Delaware', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'DC', 'districtName of Columbia', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'FL', 'Florida', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'GA', 'Georgia', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'HI', 'Hawaii', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'ID', 'Idaho', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'IL', 'Illinois', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'IN', 'Indiana', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'IA', 'Iowa', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'KS', 'Kansas', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'KY', 'Kentucky', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'LA', 'Louisiana', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'ME', 'Maine', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'MD', 'Maryland', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'MA', 'Massachusetts', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'MI', 'Michigan', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'MN', 'Minnesota', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'MS', 'Mississippi', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'MO', 'Missouri', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'MT', 'Montana', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'NE', 'Nebraska', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'NV', 'Nevada', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'NH', 'New Hampshire', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'NJ', 'New Jersey', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'NM', 'New Mexico', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'NY', 'New York', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'NC', 'North Carolina', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'ND', 'North Dakota', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'OH', 'Ohio', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'OK', 'Oklahoma', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'OR', 'Oregon', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'PA', 'Pennsylvania', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'RI', 'Rhode Island', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'SC', 'South Carolina', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'SD', 'South Dakota', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'TN', 'Tennessee', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'TX', 'Texas', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'UT', 'Utah', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'VT', 'Vermont', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'VA', 'Virginia', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'WA', 'Washington', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'WV', 'West Virginia', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'WI', 'Wisconsin', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'WY', 'Wyoming', @user, GETDATE());
	END
	IF (@flag = 'Nepal')
	BEGIN
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'ME', 'Mechi', @user, GETDATE());
			SET @stateId = SCOPE_IDENTITY()
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1001', 'Ilam', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1001', 'Jhapa', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1001', 'Panchthar', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1001', 'Taplejung', @user, GETDATE());
		
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'KO', 'Koshi', @user, GETDATE());
			SET @stateId = SCOPE_IDENTITY()
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1001', 'Bhojpur', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1001', 'Dhankuta', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1001', 'Morang', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1001', 'Sankhuwasabha', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1001', 'Sunsari', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1001', 'Terhathum', @user, GETDATE());
			
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'SA', 'Sagarmatha', @user, GETDATE());
			SET @stateId = SCOPE_IDENTITY()
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1001', 'Khotang', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1001', 'Okhaldhunga', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1001', 'Saptari', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1001', 'Siraha', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1001', 'Solukhumbu', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1001', 'Udayapur', @user, GETDATE());
			
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'JA', 'Janakpur', @user, GETDATE());
			SET @stateId = SCOPE_IDENTITY()
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1002', 'Dhanusa', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1002', 'Dolakha', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1002', 'Mahottari', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1002', 'Ramechhap', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1002', 'Sarlahi', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1002', 'Sindhuli', @user, GETDATE());
			
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'BA', 'Bagmati', @user, GETDATE());
			SET @stateId = SCOPE_IDENTITY()
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1002', 'Bhaktapur', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1002', 'Dhading', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1002', 'Kathmandu', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1002', 'Kavrepalanchok', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1002', 'Lalitpur', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1002', 'Nuwakot', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1002', 'Rasuwa', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1002', 'Sindhupalchok', @user, GETDATE());
			
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'GA', 'Gandaki', @user, GETDATE());
			SET @stateId = SCOPE_IDENTITY()
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1003', 'Gorkha', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1003', 'Kaski', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1003', 'Lamjung', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1003', 'Manang', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1003', 'Syangja', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1003', 'Tanahu', @user, GETDATE());
			
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'NA', 'Narayani', @user, GETDATE());
			SET @stateId = SCOPE_IDENTITY()
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1002', 'Bara', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1002', 'Chitwan', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1002', 'Makwanpur', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1002', 'Parsa', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1002', 'Rautahat', @user, GETDATE());
			
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'KA', 'Karnali', @user, GETDATE());
			SET @stateId = SCOPE_IDENTITY()
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1004', 'Dolpa', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1004', 'Humla', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1004', 'Jumla', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1004', 'Kalikot', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1004', 'Mugu', @user, GETDATE());
			
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'RA', 'Rapti', @user, GETDATE());
			SET @stateId = SCOPE_IDENTITY()
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1004', 'Dang Deukhuri', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1004', 'Pyuthan', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1004', 'Rolpa', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1004', 'Rukum', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1004', 'Salyan', @user, GETDATE());
			
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'BH', 'Bheri', @user, GETDATE());
			SET @stateId = SCOPE_IDENTITY()
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1004', 'Banke', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1004', 'Bardiya', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1004', 'Dailekh', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1004', 'Jajarkot', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1004', 'Surkhet', @user, GETDATE());
			
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'SE', 'Seti', @user, GETDATE());
			SET @stateId = SCOPE_IDENTITY()
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1005', 'Achham', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1005', 'Bajang', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1005', 'Bajura', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1005', 'Doti', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1005', 'Kailali', @user, GETDATE());
			
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'DH', 'Dhawalagiri', @user, GETDATE());
			SET @stateId = SCOPE_IDENTITY()
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1003', 'Baglung', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1003', 'Mustang', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1003', 'Myagdi', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1003', 'Parbat', @user, GETDATE());
			
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'LU', 'Lumbini', @user, GETDATE());
			SET @stateId = SCOPE_IDENTITY()
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1003', 'Arghakhanchi', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1003', 'Gulmi', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1003', 'Kapilvastu', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1003', 'Nawalparasi', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1003', 'Palpa', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1003', 'Rupandehi', @user, GETDATE());
			
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'MA', 'Mahakali', @user, GETDATE());
			SET @stateId = SCOPE_IDENTITY()
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1005', 'Baitadi', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1005', 'Dadeldhura', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1005', 'Darchula', @user, GETDATE());
			INSERT INTO zonedistrictMap (zone, regionId, districtName, createdBy, createdDate) values (@stateId, '1005', 'Kanchanpur', @user, GETDATE());
	END
	IF(@flag = 'Australia')
	BEGIN
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'NSW', 'New South Wales', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'QLD', 'QueensLand', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'SA', 'South Australia', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'TAS', 'Tasmania', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'VIC', 'Victoria', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, 'WA', 'Western Australia', @user, GETDATE());	
	END
	IF(@flag = 'Japan')
	BEGIN
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Aichi', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Akita', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Aomori', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Chiba', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Ehime', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Fukui', @user, GETDATE());
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Fukuoka', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Fukushima', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Gifu', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Gumma', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Hiroshima', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Hokkaido', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Hyogo', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Ibaragi', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Ishikawa', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Iwate', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Kagawa', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Kagoshima', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Kanagawa', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Kochi', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Kumamoto', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Kyoto', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Mie', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Miyagi', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Miyazaki', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Nagano', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Nagasaki', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Nara', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Niigata', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Oita', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Okayama', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Okinawa', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Osaka', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Saga', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Saitama', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Shiga', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Shimane', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Shizuoka', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Tochigi', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Tokushima', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Tokyo', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Tottori', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Toyama', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Wakayama', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Yamagata', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Yamaguchi', @user, GETDATE()); 
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values (@countryId, '', 'Yamanashi', @user, GETDATE()); 
	END
	IF(@flag = 'Malaysia')
	BEGIN
		insert into countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) values 
		(@countryId, 'JOH', 'Johor', @user, GETDATE()),
		(@countryId, 'KDH', 'Kedah', @user, GETDATE()),
		(@countryId, 'KEL', 'Kelantan', @user, GETDATE()), 
		(@countryId, 'MEL', 'Melaka', @user, GETDATE()),
		(@countryId, 'NS', 'Negeri Sembilan', @user, GETDATE()),
		(@countryId, 'PAH', 'Pahang', @user, GETDATE()), 
		(@countryId, 'PRK', 'Perak', @user, GETDATE()), 
		(@countryId, 'PER', 'Perlis', @user, GETDATE()), 
		(@countryId, 'PP', 'Pulau Pinang', @user, GETDATE()),
		(@countryId, 'SAB', 'Sabah', @user, GETDATE()), 
		(@countryId, 'SWK', 'Sarawak', @user, GETDATE()), 
		(@countryId, 'SEL', 'Selangor', @user, GETDATE()), 
		(@countryId, 'TER', 'Terengganu', @user, GETDATE()), 
		(@countryId, 'KL', 'Wilayah Persekutuan Kuala Lumpur', @user, GETDATE()), 
		(@countryId, 'LAB', 'Wilayah Persekutuan Labuan', @user, GETDATE()), 
		(@countryId, 'PUT', 'Wilayah Persekutuan Putrajaya', @user, GETDATE());
	END
	IF(@flag = 'India')
	BEGIN
		INSERT INTO countryStateMaster (countryId, stateCode, stateName, createdBy, createdDate) VALUES
		(@countryId , '', 'Andaman Nicobar', @user, GETDATE()),
		(@countryId , '', 'Andhra Pradesh', @user, GETDATE()),
		(@countryId , '', 'Arunachal Pradesh', @user, GETDATE()),
		(@countryId , '', 'Assam', @user, GETDATE()),
		(@countryId , '', 'Bihar', @user, GETDATE()),
		(@countryId , '', 'Chandigarh', @user, GETDATE()),
		(@countryId , '', 'Chhattisgarh', @user, GETDATE()),
		(@countryId , '', 'Dadra Nagar Haveli', @user, GETDATE()),
		(@countryId , '', 'Daman Diu', @user, GETDATE()),
		(@countryId , '', 'Delhi', @user, GETDATE()),
		(@countryId , '', 'Goa', @user, GETDATE()),
		(@countryId , '', 'Gujarat', @user, GETDATE()),
		(@countryId , '', 'Haryana', @user, GETDATE()),
		(@countryId , '', 'Himachal Pradesh', @user, GETDATE()),
		(@countryId , '', 'Jammu Kashmir', @user, GETDATE()),
		(@countryId , '', 'Jharkhand', @user, GETDATE()),
		(@countryId , '', 'Karnataka', @user, GETDATE()),
		(@countryId , '', 'Kerala', @user, GETDATE()),
		(@countryId , '', 'Lakshadweep', @user, GETDATE()),
		(@countryId , '', 'Madhya Pradesh', @user, GETDATE()),
		(@countryId , '', 'Maharashtra', @user, GETDATE()),
		(@countryId , '', 'Manipur', @user, GETDATE()),
		(@countryId , '', 'Meghalaya', @user, GETDATE()),
		(@countryId , '', 'Mizoram', @user, GETDATE()),
		(@countryId , '', 'Nagaland', @user, GETDATE()),
		(@countryId , '', 'Orissa', @user, GETDATE()),
		(@countryId , '', 'Pondicherry', @user, GETDATE()),
		(@countryId , '', 'Punjab', @user, GETDATE()),
		(@countryId , '', 'Rajasthan', @user, GETDATE()),
		(@countryId , '', 'Sikkim', @user, GETDATE()),
		(@countryId , '', 'Tamil Nadu', @user, GETDATE()),
		(@countryId , '', 'Tripura', @user, GETDATE()),
		(@countryId , '', 'Uttar Pradesh', @user, GETDATE()),
		(@countryId , '', 'Uttaranchal', @user, GETDATE()),
		(@countryId , '', 'West Bengal', @user, GETDATE());
	END
	EXEC proc_errorHandler 0, 'State Generated', @countryId
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id
END CATCH

GO
