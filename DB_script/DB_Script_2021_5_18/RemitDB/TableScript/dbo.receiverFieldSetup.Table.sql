USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[receiverFieldSetup]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[receiverFieldSetup](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[pCountry] [int] NOT NULL,
	[paymentMethodId] [int] NULL,
	[field] [varchar](50) NOT NULL,
	[fieldRequired] [char](1) NOT NULL,
	[minfieldLength] [int] NULL,
	[maxfieldLength] [int] NULL,
	[KeyWord] [varchar](50) NULL,
	[createdBy] [varchar](50) NOT NULL,
	[createdDate] [datetime] NOT NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[isDropDown] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[receiverFieldSetup] ADD  DEFAULT (getdate()) FOR [createdDate]
GO
