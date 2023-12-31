USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[tran_master_bak]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tran_master_bak](
	[tran_id] [int] IDENTITY(10000,1) NOT NULL,
	[acc_num] [varchar](25) NULL,
	[entry_user_id] [varchar](20) NULL,
	[gl_sub_head_code] [varchar](10) NULL,
	[part_tran_srl_num] [varchar](4) NULL,
	[part_tran_type] [varchar](2) NULL,
	[ref_num] [varchar](20) NULL,
	[rpt_code] [varchar](25) NULL,
	[tran_amt] [money] NULL,
	[tran_date] [datetime] NULL,
	[billno] [varchar](50) NULL,
	[tran_type] [varchar](20) NULL,
	[created_date] [datetime] NULL,
	[company_id] [int] NULL,
	[CHEQUE_NO] [varchar](50) NULL,
	[RunningBalance] [money] NULL,
	[F_PRINT] [varchar](1) NULL,
	[acct_type_code] [varchar](20) NULL,
	[usd_amt] [money] NULL,
	[usd_rate] [money] NULL,
	[branchId] [int] NULL,
	[departmentId] [int] NULL,
	[employeeName] [varchar](100) NULL,
	[field1] [varchar](50) NULL,
	[field2] [varchar](50) NULL,
	[fcy_Curr] [varchar](3) NULL,
	[dept_id] [int] NULL,
	[branch_id] [int] NULL,
	[emp_name] [varchar](100) NULL,
	[SendMargin] [money] NULL
) ON [PRIMARY]
GO
