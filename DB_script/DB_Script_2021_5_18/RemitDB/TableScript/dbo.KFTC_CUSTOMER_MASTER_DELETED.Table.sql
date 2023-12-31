USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[KFTC_CUSTOMER_MASTER_DELETED]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KFTC_CUSTOMER_MASTER_DELETED](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[customerId] [bigint] NOT NULL,
	[userSeqNo] [varchar](10) NULL,
	[accessToken] [varchar](50) NULL,
	[tokenType] [varchar](10) NULL,
	[expiresIn] [int] NULL,
	[accessTokenRegTime] [datetime] NULL,
	[accessTokenExpTime] [datetime] NULL,
	[refreshToken] [varchar](50) NULL,
	[scope] [varchar](30) NULL,
	[userCi] [varchar](4000) NULL,
	[userName] [nvarchar](100) NULL,
	[userInfo] [varchar](8) NULL,
	[userGender] [char](1) NULL,
	[userCellNo] [varchar](15) NULL,
	[userEmail] [varchar](100) NULL,
	[ApprovedBy] [varchar](50) NULL,
	[ApprovedDate] [datetime] NULL,
	[AccountSyncDT] [datetime] NULL,
	[accHolderInfoType] [varchar](100) NULL,
	[accHolderInfo] [varchar](50) NULL,
	[RejectedBy] [varchar](50) NULL,
	[RejectedDate] [datetime] NULL,
	[RejectNote] [varchar](200) NULL,
 CONSTRAINT [PK_KFTC_CUSTOMER_MASTER_DELETED] PRIMARY KEY CLUSTERED 
(
	[customerId] ASC,
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
