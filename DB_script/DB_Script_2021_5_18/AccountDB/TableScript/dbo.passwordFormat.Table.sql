USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[passwordFormat]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[passwordFormat](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[loginAttemptCount] [int] NULL,
	[minPwdLength] [int] NULL,
	[pwdHistoryNum] [int] NULL,
	[specialCharNo] [int] NULL,
	[numericNo] [int] NULL,
	[capNo] [int] NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[lockUserDays] [float] NULL,
	[chkCddOn] [money] NULL,
	[chkeddOn] [money] NULL,
	[txnApproveAmt] [money] NULL,
	[holdCustTxnMoreBrnch] [money] NULL,
	[onBehalfLimit] [money] NULL
) ON [PRIMARY]
GO
