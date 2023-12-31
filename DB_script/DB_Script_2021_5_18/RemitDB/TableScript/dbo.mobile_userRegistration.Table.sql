USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[mobile_userRegistration]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mobile_userRegistration](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[customerId] [int] NULL,
	[clientId] [varchar](50) NULL,
	[username] [varchar](50) NULL,
	[OTP] [varchar](50) NULL,
	[OTP_Used] [bit] NULL,
	[createdDate] [datetime] NOT NULL,
	[IMEI] [varchar](100) NULL,
	[appVersion] [varchar](50) NULL,
	[phoneBrand] [varchar](50) NULL,
	[phoneOs] [varchar](50) NULL,
	[osVersion] [varchar](50) NULL,
	[deviceId] [nvarchar](max) NULL,
	[accessCode] [varchar](500) NULL,
	[accessCodeExpiry] [datetime] NULL,
	[passRecoveryCode] [varchar](50) NULL,
	[passRecoveryCodeUsed] [bit] NULL,
	[cmRegistrationId] [varchar](300) NULL,
	[lastLoggedInDevice] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[mobile_userRegistration] ADD  DEFAULT (getdate()) FOR [createdDate]
GO
