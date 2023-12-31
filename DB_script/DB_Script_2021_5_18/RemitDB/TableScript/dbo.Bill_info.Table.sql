USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[Bill_info]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Bill_info](
	[bill_id] [int] NOT NULL,
	[party_code] [varchar](100) NULL,
	[billno] [varchar](50) NOT NULL,
	[bill_date] [datetime] NULL,
	[taxable_amt] [money] NULL,
	[nontax_amt] [money] NULL,
	[vat_amt] [money] NULL,
	[bill_amount] [money] NULL,
	[bill_discount] [money] NULL,
	[paid_amount] [money] NULL,
	[bill_type] [char](1) NULL,
	[last_paid_date] [datetime] NULL,
	[bill_notes] [varchar](max) NULL,
	[entered_by] [varchar](50) NULL,
	[entered_date] [datetime] NULL,
	[modified_by] [varchar](50) NULL,
	[modified_date] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_Bill_info_bill_id] PRIMARY KEY CLUSTERED 
(
	[bill_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Bill_info] ADD  CONSTRAINT [MSrepl_tran_version_default_EA0F4B94_809A_4B3C_BB04_8B2894E274EB_2099048]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
