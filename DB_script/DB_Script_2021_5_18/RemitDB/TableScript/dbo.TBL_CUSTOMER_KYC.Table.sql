USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TBL_CUSTOMER_KYC]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_CUSTOMER_KYC](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[customerId] [int] NOT NULL,
	[kycMethod] [int] NOT NULL,
	[kycStatus] [int] NULL,
	[remarks] [nvarchar](200) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[isDeleted] [bit] NOT NULL,
	[deletedBy] [varchar](30) NULL,
	[deletedDate] [datetime] NULL,
	[KYC_DATE] [datetime] NULL,
	[trackingNo] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TBL_CUSTOMER_KYC] ADD  DEFAULT ((0)) FOR [isDeleted]
GO
