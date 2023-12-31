USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[sendingAmtThresholdHistory]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sendingAmtThresholdHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[sAmtThresholdId] [bigint] NULL,
	[sCountryId] [int] NULL,
	[sCountryName] [varchar](150) NULL,
	[rCountryId] [int] NULL,
	[rCountryName] [varchar](150) NULL,
	[sAgent] [int] NULL,
	[Amount] [money] NULL,
	[MessageTxt] [nvarchar](max) NULL,
	[isEnable] [char](1) NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[modType] [varchar](6) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
